package Sanger::CGP::Pindel::Implement;

use strict;
use warnings FATAL => 'all';
use autodie qw(:all);
use Const::Fast qw(const);
use File::Spec;
use File::Which qw(which);
use File::Path qw(make_path);
use File::Temp qw(tempfile);
use Capture::Tiny;
use List::Util qw(first);

use Sanger::CGP::Pindel;
our $VERSION = Sanger::CGP::Pindel->VERSION;

use PCAP::Threaded;
use PCAP::Bam;

const my $PINDEL_GEN_COMM => ' -b %s -o %s -t %s';
const my $SAMTOOLS_FAIDX => ' faidx %s %s > %s';
const my $FILTER_PIN_COMM => ' %s %s %s %s';
const my $PINDEL_COMM => ' %s %s %s %s %s %s';

sub prepare {
  my $options = shift;
  $options->{'tumour_name'} = (PCAP::Bam::sample_name($options->{'tumour'}))[0];
  $options->{'normal_name'} = (PCAP::Bam::sample_name($options->{'normal'}))[0];
  return 1;
}

sub input {
  my ($index, $options) = @_;
  return 1 if(exists $options->{'index'} && $index != $options->{'index'});

  my $tmp = $options->{'tmp'};
  return 1 if PCAP::Threaded::success_exists(File::Spec->catdir($tmp, 'progress'), $index);

  my @inputs = ($options->{'tumour'}, $options->{'normal'});
  my $iter = 1;
  for my $input(@inputs) {
    next if($iter++ != $index); # skip to the relevant input in the list

    ## build command for this index
    #

    my $max_threads = ($options->{'threads'} > 3) ? 2 : 1;

    my $sample = sanitised_sample_from_bam($input);
    my $gen_out = File::Spec->catdir($tmp, $sample);
    make_path($gen_out);

    my $command = "$^X ";
    $command .= which('pindel_input_gen.pl');
    $command .= sprintf $PINDEL_GEN_COMM, $input, $gen_out, $max_threads;

    #
    ## The rest is auto-magical

    PCAP::Threaded::external_process_handler(File::Spec->catdir($tmp, 'logs'), $command, $index);
    PCAP::Threaded::touch_success(File::Spec->catdir($tmp, 'progress'), $index);
  }
  return 1;
}

sub split {
  my ($index, $options) = @_;
  return 1 if(exists $options->{'index'} && $index != $options->{'index'});

  my $tmp = $options->{'tmp'};
  return 1 if PCAP::Threaded::success_exists(File::Spec->catdir($tmp, 'progress'), $index);

  my @seqs = sort keys %{$options->{'seqs'}};
  my $iter = 1;
  for my $seq(@seqs) {
    next if($iter++ != $index); # skip to the relevant seq in the list

    ## build command for this index
    #

    my $gen_out = File::Spec->catdir($tmp, 'refs');
    make_path($gen_out);

    my $command = which('samtools');
    $command .= sprintf $SAMTOOLS_FAIDX,  $options->{'reference'},
                                          $seq,
                                          File::Spec->catfile($gen_out, "$seq.fa");

    #
    ## The rest is auto-magical

    PCAP::Threaded::external_process_handler(File::Spec->catdir($tmp, 'logs'), $command, $index);
    PCAP::Threaded::touch_success(File::Spec->catdir($tmp, 'progress'), $index);
  }
  return 1;
}

sub filter {
  my ($index, $options) = @_;
  return 1 if(exists $options->{'index'} && $index != $options->{'index'});

  my $tmp = $options->{'tmp'};
  return 1 if PCAP::Threaded::success_exists(File::Spec->catdir($tmp, 'progress'), $index);

  my @seqs = sort keys %{$options->{'seqs'}};
  my $iter = 1;
  for my $seq(@seqs) {
    next if($iter++ != $index); # skip to the relevant seq in the list

    ## build command for this index
    #

    my $gen_out = File::Spec->catdir($tmp, 'filter');
    make_path($gen_out);

    my $refs = File::Spec->catdir($tmp, 'refs');

    my $command = which('filter_pindel_reads');
    $command .= sprintf $FILTER_PIN_COMM, File::Spec->catfile($refs, "$seq.fa"),
                                          $seq,
                                          File::Spec->catfile($gen_out, $seq),
                                          (join q{ }, @{$options->{'seqs'}->{$seq}});

    #
    ## The rest is auto-magical

    PCAP::Threaded::external_process_handler(File::Spec->catdir($tmp, 'logs'), $command, $index);
    PCAP::Threaded::touch_success(File::Spec->catdir($tmp, 'progress'), $index);
  }
  return 1;
}

sub pindel {
  my ($index, $options) = @_;
  return 1 if(exists $options->{'index'} && $index != $options->{'index'});

  my $tmp = $options->{'tmp'};
  return 1 if PCAP::Threaded::success_exists(File::Spec->catdir($tmp, 'progress'), $index);

  my @seqs = sort keys %{$options->{'seqs'}};
  my $iter = 1;
  for my $seq(@seqs) {
    next if($iter++ != $index); # skip to the relevant seq in the list

    ## build command for this index
    #

    my $gen_out = File::Spec->catdir($tmp, 'pout');
    make_path($gen_out);

    my $filtered = File::Spec->catdir($tmp, 'filter');
    my $refs = File::Spec->catdir($tmp, 'refs');
    my ($bd_fh, $bd_file) = tempfile('pindel_db_XXXX', UNLINK => 1);
    close $bd_fh;

    my $command = which('pindel');
    $command .= sprintf $PINDEL_COMM, File::Spec->catfile($refs, "$seq.fa"),
                                      File::Spec->catfile($filtered, $seq),
                                      $gen_out,
                                      $seq,
                                      $bd_file,
                                      5;

    #
    ## The rest is auto-magical

    PCAP::Threaded::external_process_handler(File::Spec->catdir($tmp, 'logs'), $command, $index);
    PCAP::Threaded::touch_success(File::Spec->catdir($tmp, 'progress'), $index);
  }
  return 1;
}

sub sanitised_sample_from_bam {
  my $sample = (PCAP::Bam::sample_name(shift))[0];
  $sample =~ s/[^\/a-z0-9_-]/_/ig; # sanitise sample name
  return $sample;
}

sub determine_jobs {
  my $options = shift;
  my $tmp = $options->{'tmp'};
  my @exclude;
  @exclude = split /,/, $options->{'exclude'} if(exists $options->{'exclude'});
  my %seqs;
  for my $in_bam($options->{'tumour'}, $options->{'normal'}) {
    my $samp_path = File::Spec->catdir($tmp, sanitised_sample_from_bam($in_bam));
    my @files = file_list($samp_path, qr/\.txt$/);
    for my $file(@files) {
      my ($seq) = $file =~ m/(.+)\.txt$/;
      next if(first { $seq eq $_ } @exclude);
      push @{$seqs{$seq}}, File::Spec->catfile($samp_path, $file);
    }
  }
  $options->{'seqs'} = \%seqs;
  my @seqs = keys %seqs;
  return scalar @seqs;
}

sub file_list {
  my ($dir, $regex) = @_;
  my @files;
  opendir(my $dh, $dir) || die;
  while(readdir $dh) {
    push @files, $_ if($_ =~ $regex);
  }
  closedir $dh;
  return @files;
}

1;