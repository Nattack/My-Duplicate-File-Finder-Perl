#!/usr/bin/perl

# Duplicate file finder, 
# finds duplicate files based on SHA-1 hash.
# 
# deletes all found duplicates.

# requires Digest::SHA1 to be installed from CPAN.

		use 5.010;
		use Digest::SHA1;

		my $subbit; if ($ARGV[0] eq "R") { $subbit = 1; } else { $subbit = 0; }
		my $sha1 = Digest::SHA1->new;
		my @flatSHA1;		# Array that holds all found 
		my $hash;
	
	# start by getting all files, then convert to hash
		foreach my $filename ( &getFiles( $ENV{'PWD'}, $subbit ) )
		{
		
	# Get SHA-1 hash.
			open (FILE, "<", $filename);
			$sha1->addfile(FILE);

			$hash = $sha1->hexdigest;

			$sha1->reset;
			close FILE;
			
	#test for duplicates, if none found, add to SHA-1 list, else delete the file.
			unless (@flatSHA1 ~~ $hash)
			{
				push (@flatSHA1, $hash);
			} else {
				unlink $filename;
			}
					
		}
	
# returns an array of files. 
# if element 1 is 1, recurse directories.
	sub getFiles
	{
		my $directory = $_[0];
		my @files;
		my @filelist;
		my @subdirs;

	# remove trailing slash if present
		$directory =~ s/\/$//; 

	# iterate through directory
		chdir $directory;
		@filelist = glob "*";
		
		foreach my $filename (@filelist)
		{			
	# if you are to recurse through subdirectories, recurse this subroutine to get all the files. 
			if ( $_[1] == 1 ) 
			{
				if ( -d $filename ) 
				{	
					push ( @subdirs, $filename );
				}
			}
			push (@files, $directory . "/" .$filename) unless (-d $directory . "/" . $filename);
		}
		
	# if subdirectories were found, find files in them as well.
		foreach my $dirname (@subdirs)
		{
			push( @files, &getFiles($directory . "/" . $dirname, 1) );
		}
		
		return @files;
	}