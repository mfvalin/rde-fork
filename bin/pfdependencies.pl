#!/usr/bin/perl
require 5.010_001;
#require 5.10.1;
#use warnings;        # Avertissement des messages d'erreurs
#use strict;          # Verification des declarations
use File::Spec::Functions;
use File::Basename;
use URI::file;
use Cwd "realpath";
use Getopt::Long;
my $msg =  2;
my %msgl = ("q", 0 , "e", 1 ,"w", 2 ,"v", 3 ,"vv", 4, "vvv", 5 ) ;
my $items_per_line = 4 ;   # number of items per Makefile line
my $item_count = 0;
my $ext = undef;
my @listfile;
my %listdir = ();
my @includelist;
my $use_strict = undef;
my $deep_include = undef;
my $soft_restriction = undef; # soft_restriction = disable warning if 2 headers files have the same name
my $flat_layout = undef;
my $short_target_names = undef;
my $local_dir = undef;
my $dup_ok = undef;
my $side_dir_inc = undef;
my $anywhere_inc = undef;
my $export_list = undef;
my @current_dependencies_list = ();
my @outside_tree_list = ();
my %module_missing = ();
my %module_missing_ignored = ();
my %include_missing_ignored = ();
my %LISTOBJECT = ( ); # Hash of SRCFile object with filename, path and extension as the key

#########################################################################
# Process command line arguments
#########################################################################
my $help = 0;
my $output_file='';
my $include_dirs='';
my $suppress_errors_file='';
GetOptions('verbose:+' => \$msg,
           'quiet' => sub{$msg=0;},
           'help' => \$help,
           'flat_layout' => \$flat_layout,
           'short_target_names' => \$short_target_names,
           # 'local' => \$local_dir,
           # 'dup_ok' => \$dup_ok,
           'side_dir_inc' => \$side_dir_inc,
           'any_inc' => \$anywhere_inc,
           'strict' => \$use_strict,
           'deep-include' => \$deep_include,
           'soft-restriction' => \$soft_restriction,
           'exp=s' => \$export_list,
           'out=s' => \$output_file,
           'includes=s' => \$include_dirs,
           'supp=s' => \$suppress_errors_file,
    )
    or $help=1;

@listfile = (@ARGV);
if (!$help and !($#listfile+1)) {
    $help=1;
    print STDERR "ERRROR: you must provide a list of targets\n"
}
if ($help) {
    print STDERR "
Usage: s.dependencies.pl [-v|--quiet] \\
                         [--strict] [--deep-include] [--soft-restriction] \\
                         [--flat_layout] [--short_target_names] \\
                         [--exp=output_of_produced_file] [--out=outfile] \\
                         [--side_dir_inc] [--any_inc] \\
                         [--includes=list_of_inc_dirs]  \\ 
                         list_of_targets
       list_of_targets : must be a list of files or dirs
       list_of_inc_dirs: must be a list of ':'-separated dirs\n\n";
    exit;
}

print STDERR "
s.dependencies.pl \\
   -v=$msg --strict=$use_strict --deep-include=$deep_include --soft-restriction=$soft_restriction \\
   --flat_layout=$flat_layout --short_target_names=$short_target_names \\
   --exp=$export_list --out=$output_file \\
   --side_dir_inc=$side_dir_inc --any_inc=$anywhere_inc \\
   --includes=$include_dirs \\
   ...
   \n" if ($msg>=3);

#########################################################################
# List of function and object definition
#########################################################################

{ package SRCFile ; {
    # List of the type of file associated with the extension
    our %TYPE_LIST = (
        f     => "COMPILABLE",
        ftn   => "COMPILABLE",
        ptn   => "", #INCLUDE,
        f90   => "COMPILABLE",
        ftn90 => "COMPILABLE",
        ptn90 => "", #INCLUDE,
        cdk   => "", #INCLUDE,
        cdk90 => "COMPILABLE",
        c     => "COMPILABLE",
        h     => "", #INCLUDE,
        hf    => "", #INCLUDE,
        fh    => "", #INCLUDE,
        inc   => "", #INCLUDE,
        tmpl90 => "COMPILABLE",
    );

    # @new: Constructor of the SRCFile Object
    # IN :
    #   $1 = {
    #           path => 
    #           filename =>
    #           extension =>
    #        }
    # OUT: pointer to the object
    sub new {
        my ( $class, $ref_arguments ) = @_;
        
        $class = ref($class) || $class;
        my $this = {};
        bless( $this, $class );
            
        $this->{FULLPATH_SRC}     = " ";
        $this->{FILENAME}         = " ";
        $this->{EXTENSION}        = " ";
        $this->{FULLPATH_SRC}     = $ref_arguments->{path}; 
        $this->{FILENAME}         = $ref_arguments->{filename};
        $this->{EXTENSION}        = $ref_arguments->{extension};
        $this->{PATHyNAME}        = "$this->{FULLPATH_SRC}$this->{FILENAME}";
        $this->{NAMEyEXT}         = "$this->{FILENAME}.$this->{EXTENSION}";
        $this->{PATHyNAMEyEXT}    = "$this->{FULLPATH_SRC}$this->{NAMEyEXT}";
      %{$this->{DEPENDENCIES}}    = ();   # A list to the required file
        $this->{COMPILABLE}       = $TYPE_LIST{lc $this->{EXTENSION}};
        $this->{STATUS}           = undef;
      @{$this->{UNSOLVED_MODULE}} = ();
      @{$this->{MODULE_LIST}}     = ();
      %{$this->{UNKNOWN_MODULE}}  = ();
      %{$this->{UNKOWN_USE}}      = ();
        return $this;
    }

    # @has_module: find if the object defined the module 
    # IN : $1 = Module name to find
    # OUT: true (1) if the module as been found, false (undef) otherwise
    sub has_module {
        my $module_name = $_[1];    
        for (@{$_[0]->{MODULE_LIST}}) {
            return 1 if $_ eq $module_name;
        }
        return undef;
    }

    # @has_unsolved_module: find if the object has the module in his unsolved module list
    # IN : $1 = Module name to find
    # OUT: true (1) if the module as been found, false (undef) otherwise
    sub has_unsolved_module {
        my $module_name = $_[1];        
        for (@{$_[0]->{UNSOLVED_MODULE}}) {
            return 1 if ($_ eq $module_name);
        }
        return undef;
    }

    # @remove_unsolved_module: delete the module in the unsolved module list
    # IN : $1 = Module name to delete
    # OUT: none
    sub remove_unsolved_module {
        my $module_name = "$_[1]";
        my $idx = 0;
        for my $module (@{$_[0]->{UNSOLVED_MODULE}}) {
            if ($module eq $module_name) { 
                delete ${$_[0]->{UNSOLVED_MODULE}}[$idx]; 
            } 
            $idx++; 
        }
    }

    # @find_dependencies: find if the object has the filename in his depedencie list
    # IN : $1 = filename to search
    # OUT: true (1) if the module as been found, false (undef) otherwise
    sub find_dependencies {
        my $search_depedencies = "$_[1]";
        for my $dep_filename (keys %{$_[0]->{DEPENDENCIES}}) {
            my $dep_ptr = ${$_[0]->{DEPENDENCIES}}{$dep_filename};
            return 1 if (($search_depedencies eq $dep_filename) and ($_[0]->{FULLPATH_SRC} ne $dep_ptr->{FULLPATH_SRC} ) );
            return undef if (($search_depedencies eq $dep_filename) and ($_[0]->{FULLPATH_SRC} eq $dep_ptr->{FULLPATH_SRC} ) );
            return 1 if ($dep_ptr->SRCFile::find_dependencies($search_depedencies) );
        }
        return undef;
    }

}} #end package SRCFile

#------------------------------------------------------------------------
# @preproc_suppfile: Pre-Process suppress_errors_file
#------------------------------------------------------------------------
sub preproc_suppfile {
    my $suppfile = $_[0];
    if ($suppfile) {
        print STDERR "Processing suppress_errors_file: $suppfile\n" if ($msg >= 3);
        if (!open(INPUT,"<", $suppfile)) {
            print STDERR "ERROR: Can't open supp file, ignoring: ".$suppfile."\n";
        } else {
            while (<INPUT>) {
                if ($_ =~ /^[\s]*module_missing[\s]+([^\s]+)/i) {
                    print STDERR "Suppressing missing mod msg for: ".$1."\n" if ($msg >= 4);
                    $module_missing_ignored{$1} = 1;
                } elsif ($_ =~ /^[\s]*include_missing[\s]+([^\s]+)/i) {
                    print STDERR "Suppressing missing inc msg for: ".$1."\n" if ($msg >= 4);
                    $include_missing_ignored{$1} = 1;
                } else {
                    print STDERR "Ignoring supp file line: ".$_."\n" if ($msg >= 4);
                }
            }
            close INPUT;
        }
    }
    return undef;
}

#------------------------------------------------------------------------
# @preproc_srcfiles: Pre-Process src file
#------------------------------------------------------------------------
sub preproc_srcfiles {
    for (@listfile){
        if (-d $_) {
            print STDERR "process: '$_' $dup_ok\n" if ($msg >= 3);
            for (glob "$_/*") {
                pre_process_file($_,$dup_ok);
            }
        } else {
            print STDERR "process: '$_'\n" if ($msg >= 3);
            for (glob "$_") {
                pre_process_file($_,$dup_ok);
            }
        }
    }

    $dup_ok = 1;
    if ($local_dir) {
        for (glob "./*") {
            pre_process_file($_,$dup_ok);
        }
    }
}

#------------------------------------------------------------------------
# @process_file
# IN : 
#   $0 = file
#   $1 = ==1 if duplicatedfile_ok
# OUT: undef if ok; 1 otherwise
#------------------------------------------------------------------------
sub pre_process_file {
    return 1 if (! -f "$_[0]");
    my ($entry, $_dup_ok) = @_;

    my $file = "$entry" ;
    $file =~ s/,v$// ;
    $file =~ s/[\s]+// ;
    $file = File::Spec->abs2rel(canonpath($file), "./") if ($file =~ /^\//);
    
    return 1 if ($file !~  /(.*\/)*(.*)[.]([^.]*$)/);
    return 1 if (exists($LISTOBJECT{$file})); 
    
    my $path = ($1 ? $1 : "");
    my $filn = ($2 ? $2 : "");
    my $exte = ($3 ? $3 : "");
    
    return 1 if (!has_legal_extension($exte));

    my $duplicated_filename1 = find_same_filename2($path, "$filn.$exte");

    if ($duplicated_filename1 and $_dup_ok) {
        delete $LISTOBJECT{$duplicated_filename1};
    }

    $LISTOBJECT{"$path$filn.$exte"} = new SRCFile({path => $path, filename => $filn, extension => $exte});

    if ($duplicated_filename1 and $_dup_ok) {
        print STDERR "WARNING: $duplicated_filename1 was replaced by $path$filn.$exte : ".$LISTOBJECT{"$path$filn.$exte"}->{FILENAME}.$LISTOBJECT{"$path$filn.$exte"}->{STATUS};
    }
    
    # Error handler
    my $duplicated_filename2 = find_same_output("$path$filn.$exte");
    if ($_dup_ok) {
        if ($msg >= 1) {
            print STDERR "WARNING: using 2 files with the same name $duplicated_filename1 with $path$filn.$exte\n" if ($duplicated_filename1);
            print STDERR  "WARNING: using 2 files ($duplicated_filename2 and $path$filn.$exte) that will produce the same object file ($filn.o)\n" if ($duplicated_filename2);
        }
    } else {
        die "ERR: using 2 files with the same name $duplicated_filename1 with $path$filn.$exte" if ($duplicated_filename1);
        die "ERR: using 2 files ($duplicated_filename2 and $path$filn.$exte) that will produce the same object file ($filn.o)\n" if ($duplicated_filename2);        
    }
    # print STDERR "process: '$entry' dupok=$_dup_ok ; path=$path ; filen=$filn ; exte=$exte ; dup=$duplicated_filename1\n" if ($msg >= 5);
    return undef;
}

#------------------------------------------------------------------------
# @find_same_filename: Look if the filename is already used somewhere else
# IN : $0 = filename to compare with
# OUT: object key (filename) if file already exist, false (undef) otherwise
#------------------------------------------------------------------------
sub find_same_filename {
    my $cmp_file = $LISTOBJECT{$_[0]};
    return undef if ($soft_restriction and !$cmp_file->{COMPILABLE});
    for (keys %LISTOBJECT) {
        return $_ if (
            ($LISTOBJECT{$_}->{NAMEyEXT} eq $cmp_file->{NAMEyEXT}) and
            ($LISTOBJECT{$_}->{FULLPATH_SRC} ne $cmp_file->{FULLPATH_SRC}));
    }
    return undef;
}

#------------------------------------------------------------------------
# @find_same_filename: Look if the filename is already used somewhere else
# IN : 
#   $0 = path to filename to compare with
#   $1 = filename.ext to compare with
# OUT: object key (filename) if file already exist, false (undef) otherwise
#------------------------------------------------------------------------
sub find_same_filename2 {
    my ($mydir, $myfilename) = @_;
    for (keys %LISTOBJECT) {
        if (($LISTOBJECT{$_}->{NAMEyEXT} eq $myfilename) and
            ($LISTOBJECT{$_}->{FULLPATH_SRC} ne $mydir)) {
            return undef if ($soft_restriction and !$LISTOBJECT{$_}->{COMPILABLE});
            return $_
        }
    }
    return undef;
}

#------------------------------------------------------------------------
# @find_same_OUT: Look if the filename is already used in the Object list
# IN : $0 = Object to compare with
# OUT: object key (filename) if file already exist, false (undef) otherwise
#------------------------------------------------------------------------
sub find_same_output {
    my $cmp_file = $LISTOBJECT{$_[1]};
    return undef if (!$cmp_file->{COMPILABLE});
    for my $key (keys %LISTOBJECT) {
        return $key if (
            ($LISTOBJECT{$key}->{FILENAME} eq $cmp_file->{FILENAME}) and 
            $LISTOBJECT{$key}->{COMPILABLE} and 
            ($key ne $_[1])); 
    }
    return undef;
}

#------------------------------------------------------------------------
# @search_undone_file
#------------------------------------------------------------------------
sub search_undone_file {
    for (keys %LISTOBJECT) {
        return $_ if !$LISTOBJECT{$_}->{STATUS}; 
    }
    return undef;
}

#------------------------------------------------------------------------
# @process_file
# IN : 01 = filename
# OUT: undef if ok; 1 otherwise
#------------------------------------------------------------------------
sub process_file {
    my $filename = $_[0];
    print STDERR "Looking into $filename\n" if ($msg >= 5);
    open(INPUT,"<", $filename) or print STDERR "ERROR: Can't open file '".$filename."\n"; #  if ($msg >= 1 )
    my $file = $LISTOBJECT{$filename};
    my $line_number = 0;

    while (<INPUT>) {
        if ($_ =~ /^[@]*[\s]*#[\s]*include[\s]*[<'"\s]([\w.\/\.]+)[>"'\s][\s]*/) {
            next if (process_file_for_include($file,$1));
        }
        next if ($file->{EXTENSION} =~ /(c|cc|CC)$/);
        
        # FORTRAN include statement : include "..."    include ',,,"
        if ($_ =~ /^[@]*[\s]*include[\s]*[<'"\s]([\w.\/\.]+)[>"'\s][\s]*/i) {
            next if (process_file_for_include($file,$1));
        }
        # FORTRAN use statement : use yyy 
        if ($_ =~ /^[@]*[\s]*\buse[\s]+([a-z][\w]*)(,|\t| |$)/i) {
            my $modname = $1 ; $modname =~ tr/A-Z/a-z/ ; # modules names are case insensitive

            # If the module can be found, add the file to dependencies
            if (my $include_filename = search_module($modname)) {
                ${$file->{DEPENDENCIES}}{$include_filename} = $LISTOBJECT{$include_filename} if (!exists ${$file->{DEPENDENCIES}}{$include_filename} );
                #print STDERR "$filename +: $modname \n";
            } else {
                push @{$file->{UNSOLVED_MODULE}}, $modname; 
                #print STDERR "$filename -: $modname \n";
            }

        } elsif ($_ =~ /^[@]*[\s]*\buse[\s]+([a-z][\w]*)/i) {
            ${$file->{UNKOWN_USE}}{$line_number} = $_;
            #print STDERR "$filename ? \n";
        }

        # FORTRAN module declaration : module xxx
        if ($_ =~ /^[@]*[\s]*\bmodule[\s]+([a-z][\w]*)(,|\t| |$)/i) {
            my $modname = $1 ; $modname =~ tr/A-Z/a-z/ ; # modules names are case insensitive
            my $search_filename = '';

            next if $modname eq "procedure";

            # Verifier que le nom du module n'existe pas dans un autre fichier
            if ($search_filename = search_module($modname)) { 
                print STDERR "Module ".$modname." (".$filename.") already defined in ".$search_filename."\n"; 
                next; 
            }

            # Ajouter le module dans la liste des modules associer au fichier.
            push @{$file->{ MODULE_LIST }}, $modname;

            # Recherche tous les fichiers analyser precedemment qui avait besoin de ce module la
            while(my $key = search_unsolved_module($modname)) {
                #print STDERR "unsolved module: $key".${$LISTOBJECT{$key}->{ DEPENDENCIES }}{$filename}." : $modname \n";
                # Ajouter a la liste des dependence, le fichier en cours
                ${$LISTOBJECT{$key}->{ DEPENDENCIES }}{$filename} = $file if (!exists ${$LISTOBJECT{$key}->{ DEPENDENCIES }}{$filename} );

                # Enlever le module de la liste des unsolved modules 
                $LISTOBJECT{$key}->remove_unsolved_module($modname);
            }
        } elsif ($_ =~ /^[@]*[\s]*\bmodule[\s]+/i) {
            ${$file->{ UNKOWN_MODULE }}{$line_number} = $_;
            #print STDERR "Unknown module statement: $filename: $_\n";
        }
        $line_number++;
    }
    $file->{STATUS} = 1;
    close INPUT;
}

#------------------------------------------------------------------------
# @process_file_for_include
# IN : 
#   $0 = file object
#   $1 = filename
# OUT: undef if ok; 1 otherwise
#------------------------------------------------------------------------
sub process_file_for_include {
    my ($file, $tmp_dir) = @_;
    my $include_path = "";

    if ($tmp_dir =~ /^\.\.\//) {
        $include_path = File::Spec->abs2rel(canonpath("$file->{FULLPATH_SRC}/$tmp_dir"), "./");
    } elsif (-f canonpath("$file->{FULLPATH_SRC}/$tmp_dir")) {
        $include_path = File::Spec->abs2rel(canonpath("$file->{FULLPATH_SRC}/$tmp_dir"), "./");
    } else {
        $include_path = File::Spec->abs2rel( canonpath($tmp_dir), "./");
    }
    # print STDERR "Missing $file->{NAMEyEXT}: $tmp_dir\n" if (!$include_path and $msg>=4);
    
    if ($include_path !~  /(.*\/)*(.*)[.]([^.]*$)/) {
        # print STDERR "Outside $file->{NAMEyEXT}: $tmp_dir : $include_path\n" if ($msg>=4);
        return 1;
    }

    my $path = ($1 ? $1 : "");
    my $filn = ($2 ? $2 : "");
    my $exte = ($3 ? $3 : "");
    my $duplicated_filename = "";
    if (!has_legal_extension($exte)) {
        # print STDERR "Bad Extension $file->{NAMEyEXT}: $tmp_dir : $include_path : $exte\n" if ($msg>=4);
        return 1;
    }
    if (! -f "$path$filn.$exte") {
        if (!("$path$filn.$exte" ~~ @outside_tree_list)) {
            my $path1 = find_inc_file($file,$path,"$filn.$exte");
            if (!$path1) {
                # print STDERR "No file $file->{NAMEyEXT}: $tmp_dir : $include_path : $path$filn.$exte\n" if ($msg>=4);
                if ("$path$filn.$exte" ~~ @outside_tree_list and !exists($include_missing_ignored{"$path$filn.$exte"})) {
                    push @outside_tree_list, "$path$filn.$exte";
                }
                return 1;
            }
            # print STDERR "Found $filn.$exte in $path1\n" if ($msg >=5);
            $path = $path1;
        } else {
            return 1;
        }
    }

    # Add file in the database if it's not in yet and if the file really exists.
    $LISTOBJECT{"$path$filn.$exte"} = new SRCFile({path => $path, filename => $filn, extension => $exte}) 
        if (!exists $LISTOBJECT{"$path$filn.$exte"});

    # Force the file to not be analysed.
    $LISTOBJECT{"$path$filn.$exte"}->{STATUS} = 1 
         if (!$deep_include);

    # Error handler
    die "ERR: using 2 files with the same name $duplicated_filename with $path$filn.$exte\n" 
        if ($duplicated_filename = find_same_filename("$path$filn.$exte"));
    die "ERR: using 2 files ($duplicated_filename and $path$filn.$exte) that will produce the same object file ($filn.o)\n" 
        if ($duplicated_filename = find_same_output("$path$filn.$exte"));
    die "ERR: cannot include compilable file ($tmp_dir) in $tmp_dir while using strict mode\n" 
        if ($use_strict and $LISTOBJECT{"$path$filn.$exte"}->{COMPILABLE});

    # Add to dependencies, if not already there
    ${$file->{ DEPENDENCIES }}{"$path$filn.$exte"} = $LISTOBJECT{"$path$filn.$exte"} if (!exists ${$file->{ DEPENDENCIES }}{"$path$filn.$exte"});

    return undef;
}

#------------------------------------------------------------------------
# @has_legal_extension: 
# IN : $0 = Extension to search
# OUT: 1 if the extension is valid, undef otherwise.
#------------------------------------------------------------------------
sub has_legal_extension {
    my $search_extension = lc $_[0];
    for (keys(%SRCFile::TYPE_LIST)) {
        return 1 if $_ eq $search_extension;
    }
    return undef;
}

#------------------------------------------------------------------------
# @check_circular_dep
#------------------------------------------------------------------------
sub check_circular_dep {
    print STDERR "Checking for Circular dependencies\n" if ($msg >= 5);
    for (keys %LISTOBJECT) {
        if ($LISTOBJECT{$_}->find_dependencies($_)) { 
            print STDERR "ERR: Circular dependencies in $_ FAILED\n";
            exit 1; 
        }
    }
}

#------------------------------------------------------------------------
# @print_header: Print the first line of a dependency rule or variable list
# IN :
#   $0 = First word(s) of line
#   $1 = Seperator
#   $2 = Word/item right after seperator, empty if no word is needed
# OUT: none
#------------------------------------------------------------------------
sub print_header {
    my($item1,$separ,$item2) = @_ ;
    $item_count = 0 ;
    print STDOUT "$item1$separ" ;
    print STDOUT "\t$item2" if ( "$item1" ne "$item2" && "$item2" ne "" ) ;
}

#------------------------------------------------------------------------
# @print_item: print each item of dependency rule or variable list (items_per_line items per line)
# IN : $0 = Item to print
# OUT: none
#------------------------------------------------------------------------
sub print_item {
    if ($_[0]) {
        print STDOUT " \\\n\t" if ($item_count == 0) ;
        print STDOUT "$_[0]  ";
        $item_count = 0 if ($item_count++ >= $items_per_line);
    }
}

#------------------------------------------------------------------------
# @print_files_list
#------------------------------------------------------------------------
sub print_files_list{
    print STDERR "Listing file types FDECKS, CDECKS, ...\n" if ($msg >= 5);
    for $ext (keys %SRCFile::TYPE_LIST) {
        print_header(uc $ext."DECKS", "=", "");
        for (sort keys %LISTOBJECT) {
            my $file = $LISTOBJECT{$_};
            if (lc $file->{EXTENSION} eq lc $ext) {
                if ($flat_layout) {
                    print_item($file->{NAMEyEXT});
                } else {
                    print_item($file->{PATHyNAMEyEXT});
                }
            }
        }
        print STDOUT "\n";
    }
}

#------------------------------------------------------------------------
# @print_object_list
#------------------------------------------------------------------------
sub print_object_list {
    print STDERR "Listing OBJECTS\n" if ($msg >= 5);
    print_header("OBJECTS","=","");
    for (sort keys %LISTOBJECT) {
        my $file = $LISTOBJECT{$_};
        if ($file->{COMPILABLE}) {
            if ($flat_layout) {
                print_item("$file->{FILENAME}.o");
            } else {
                print_item("$file->{PATHyNAME}.o");
            }
            my(@dirs) = split("/",$file->{FULLPATH_SRC});
            if (!exists($listdir{$dirs[0]})) {
                @{$listdir{$dirs[0]}} = ();
            }
            if ($flat_layout) {
                push @{$listdir{$dirs[0]}},"$file->{FILENAME}.o";
            } else {
                push @{$listdir{$dirs[0]}},"$file->{PATHyNAME}.o";
            }
        }
    }
    print STDOUT "\n";

    #TODO: this should be optional
    for (keys %listdir) {
        print_header("OBJECTS_".$_,"=","");
        for my $item (@{$listdir{$_}}) {
            print_item("$item");
        }
        print STDOUT "\n";
        print STDOUT "\$(LIBDIR)/lib".$_.".a: \$(OBJECTS_".$_.") \$(LIBDEP_".$_.")\n";
        print STDOUT "\t".'rm -f $@; ar r $@_$$$$ $(OBJECTS_'.$_.'); mv $@_$$$$ $@'."\n";
        print STDOUT "lib".$_.".a: \$(LIBDIR)/lib".$_.".a\n";
    }

	 print_header("ALL_LIBS=","");
	 for (keys %listdir) {
		  print_item("\$(LIBDIR)/lib".$_.".a");
	 }
	 print STDOUT "\n";
}

#------------------------------------------------------------------------
# @print_dep_rules
#------------------------------------------------------------------------
sub print_dep_rules {
    #TODO: Dependencies to Modules should be on .mod:.o not direcly on .o (.mod could have been erased accidentaly)
    print STDERR "Printing dependencie rules\n" if ($msg >= 5);
    for my $filename (sort keys %LISTOBJECT) {
        my $file = $LISTOBJECT{$filename};
        @current_dependencies_list = ();
        if ($file->{COMPILABLE}) {
            if ($flat_layout) {
                print_header("$file->{FILENAME}.o",":",$file->{NAMEyEXT});
            } else {
                print_header("$file->{PATHyNAME}.o",":","$filename");
            }
            rec_print_dependencies(\%LISTOBJECT, $filename);
            print STDOUT "\n";
            print_header("$file->{FILENAME}.o",":","$file->{PATHyNAME}.o") if ($short_target_names and $file->{FULLPATH_SRC} and !$flat_layout);
            print STDOUT "\n";
        }
    }
}

#------------------------------------------------------------------------
# @search_module: Find the key of the object that own the module name
# IN : $0 = Module name
# OUT: object key, undef otherwise.
#------------------------------------------------------------------------
sub search_module {
    my $module_name = $_[0];
    for (keys %LISTOBJECT) {
        return $_ if ($LISTOBJECT{$_}->has_module($module_name)); 
    }
    return undef;
}

#------------------------------------------------------------------------
# @search_unsolved_module: Find the key of the first object that has the module as one of his unsolved module list
# IN : $0 = Module name to be search
# OUT: object key, undef otherwise.
#------------------------------------------------------------------------
sub search_unsolved_module {
    my $module_name = $_[0];
    for (keys %LISTOBJECT) {
        return $_ if ($LISTOBJECT{$_}->SRCFile::has_unsolved_module($module_name));
    }
    return undef;
}

#------------------------------------------------------------------------
# @rec_print_dependencies: 
# IN :
#   %0 = Hash of objects
#   $1 = Filename to print dependencies
# OUT: none
#------------------------------------------------------------------------
sub rec_print_dependencies {
    my $file = ${$_[0]}{$_[1]};
    
    #print STDERR "rec_print_dependencies: $file->{FILENAME} : $_[1]\n" if ($msg >= 5);
    #while(my($dep_filename, $dep_ptr) = each(%{$file->{DEPENDENCIES}})) {
    for my $dep_filename (sort keys %{$file->{DEPENDENCIES}}) {
         my $dep_ptr = ${$file->{DEPENDENCIES}}{$dep_filename};

        my $tmp_filename = $dep_filename;
        $tmp_filename = "$dep_ptr->{PATHyNAME}.o" if ($dep_ptr->{COMPILABLE});
        my $tmp_filename0 = $tmp_filename;
        if ($flat_layout) {
            $tmp_filename0 = "$dep_ptr->{NAMEyEXT}";
            $tmp_filename0 = "$dep_ptr->{FILENAME}.o" if ($dep_ptr->{COMPILABLE});
        }
        
        #print STDERR "$file->{FILENAME}: $dep_filename : $_[1] : $tmp_filename0 : $tmp_filename\n" if ($msg >= 5);
        next if (($_[1] eq $dep_filename) or ($tmp_filename ~~ @current_dependencies_list));

        print_item($tmp_filename0);
        push @current_dependencies_list, $tmp_filename;

        # Recursively call the function to print all depedencies
        rec_print_dependencies(\%{$_[0]}, $dep_filename) if (!$dep_ptr->{COMPILABLE});
    }
}

#------------------------------------------------------------------------
# @find_inc_file
# IN : 
#   $0 = file obj
#   $1 = supposed path to file to include
#   $2 = filename to include
# OUT: actual path to file; undef if not found
#------------------------------------------------------------------------
sub find_inc_file {
    my ($myfile, $mypath, $myfilename) = @_;
    for (@includelist) {
        if (-f $_.'/'.$mypath.$myfilename) {
            return $_.'/'.$mypath;
        } elsif (-f $_.'/'.$myfilename) {
            return $_.'/';
        }
    }
    if ($anywhere_inc) {
        for (keys %LISTOBJECT) {
            my $myobj=$LISTOBJECT{$_};
            if (($myfilename eq $myobj->{NAMEyEXT}) and 
                -f "$myobj->{PATHyNAMEyEXT}") {
                return $myobj->{FULLPATH_SRC};
            }
        }
    }
    if ($side_dir_inc) {
        my @mydirs = File::Spec->splitdir($myfile->{FULLPATH_SRC});
        for my $mysubdir ('*','*/*','*/*/*','*/*/*/*','*/*/*/*/*') {
            my @myfile2 = glob "$mydirs[0]/$mysubdir/$myfilename\n";
            if ($myfile2[0]) {
                # print STDERR "Found $myfilename in ".dirname($myfile2[0]) if ($msg >=4);
                return dirname($myfile2[0]).'/';
            }
        }
    }
    return undef;
}

#------------------------------------------------------------------------
# @print_missing: Print the missing module(s) / file(s) from the current tree
#------------------------------------------------------------------------
sub print_missing {
    #print STDERR "Includes missing from the current tree: ".join(" ",@outside_tree_list)."\n" if ($#outside_tree_list);
	 my $missing_list_string = "";
	 $missing_list_string = join(" ",@outside_tree_list) if ($#outside_tree_list);
    print STDERR "Includes missing from the current tree: ".$missing_list_string."\n" if ($missing_list_string);
    #TODO: do as module below, print first filename for each missing inc
    %module_missing = ();
    for my $filename (keys %LISTOBJECT) {
        my $file = $LISTOBJECT{$filename};
        for my $module (@{$file->{UNSOLVED_MODULE}}) {
            next if ($module eq "");
            next if (exists($module_missing_ignored{$module}));
            $module_missing{$module} = $filename if (!exists $module_missing{$module});
        }
    }
    if (keys %module_missing) {
        print STDERR "Modules missing from the current tree: ";
        while(my($module,$filename) = each(%module_missing)) {
            print STDERR "$module ($filename) ";
        }
        print STDERR "\n";
    }
}

#------------------------------------------------------------------------
# @print_unknown: Print Unknown module and use statement 
#------------------------------------------------------------------------
sub print_unknown {
    my $module_unknown = "";
    my $use_unknown = "";
    for my $filename (keys %LISTOBJECT) {
        my $file = $LISTOBJECT{$filename};
        while(my($line_number,$text_line) = each(%{$file->{UNKNOWN_MODULE}})) {
            $module_unknown .= "\t($filename) $line_number: $text_line\n";
        }
        while(my($line_number,$text_line) = each(%{$file->{UNKOWN_USE}})) {
            $use_unknown .= "\t($filename) $line_number: $text_line\n";
        }
    }
    print STDERR "Unknown module statement: \n".$module_unknown if ($module_unknown);
    print STDERR "Unknown use statement: \n".$use_unknown if ($use_unknown);
}

#------------------------------------------------------------------------
# @export_obj_list: Export a list of produced files (.o and .mod)
#------------------------------------------------------------------------
sub export_obj_list {
    open(my $EXPOUT,'>',$export_list);
    my @list_of_modules = ();
    for (keys %LISTOBJECT) {
        my $file = $LISTOBJECT{$_};
        if ($file->{COMPILABLE}) {
            if ($flat_layout) {
                print $EXPOUT "$file->{FILENAME}.o\n";
            } else {
                print $EXPOUT "$file->{PATHyNAME}.o\n";
            }
        }
        for (@{$file->{MODULE_LIST}}) {
            push @list_of_modules, $_ if $_ ne "";
        }
    }
    for (sort @list_of_modules) {
        print $EXPOUT "$_.mod\n";
    }
    close($EXPOUT);
}

#########################################################################
# Main program beginning
#########################################################################

if ($output_file) {
    print STDERR "Redirecting STDOUT to $output_file\n" if ($msg>=3);
    open(STDOUT,">", "$output_file") or die "ERROR: Can't redirect STDOUT\n";
}
@includelist = split(':',$include_dirs) if ($include_dirs);

preproc_suppfile($suppress_errors_file);

preproc_srcfiles();
while(my $filename = search_undone_file()) {
    process_file($filename);
}
check_circular_dep();

print_files_list();
print_object_list();
print_dep_rules();

print_missing();
print_unknown();

export_obj_list() if ($export_list);

