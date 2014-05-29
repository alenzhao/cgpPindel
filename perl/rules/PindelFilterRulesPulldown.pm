####################################################
# Copyright (c) 2013 Genome Research Ltd.
# Author: Cancer Genome Project, cgpit@sanger.ac.uk
# See LICENCE.TXT for details
####################################################
{
	tag  => 'INFO/LEN',
	name => 'F001',
	desc => 'Pass if Mt > Wt Reads: Likely GERMLINE',
	test => sub {
#if(pindelVariant.getpWt() >= pindelVariant.getpMt()){
#			ret = false;
#		}

		### HACK Dirty dirty dirty...... done to try and cut down the number of times I have to parse the FORMAT string I am storing it as a global variable.
		if($$RECORD[8] ne $main::previous_format_string){
			my @geno_formats = split(':',$$RECORD[8]);
			my $i = 0;
			map {$main::previous_format_hash->{$_} = $i++} split(':',$$RECORD[8]);
			$main::previous_format_string = $$RECORD[8];
		}

		my @nor_geno = split(':',$$RECORD[9]);
		my @tum_geno = split(':',$$RECORD[10]);

		if($nor_geno[$main::previous_format_hash->{'PP'}] + $nor_geno[$main::previous_format_hash->{'NP'}]  >=
			$tum_geno[$main::previous_format_hash->{'PP'}] + $tum_geno[$main::previous_format_hash->{'NP'}]){
			return $FAIL;
		}
		return $PASS;
	}
},

{
	tag  => 'INFO/LEN',
	name => 'F002',
	desc => 'No Wt calls in variants over 4bp in length: Likely GERMLINE',
	test => sub {
#if(pindelVariant.getLength() > 4 && pindelVariant.getpWt() > 0){
#			ret = false;
#		}

		if($MATCH > 4){
			### HACK Dirty dirty dirty...... done to try and cut down the number of times I have to parse the FORMAT string I am storing it as a global variable.
			if($$RECORD[8] ne $main::previous_format_string){
				my @geno_formats = split(':',$$RECORD[8]);
				my $i = 0;
				map {$main::previous_format_hash->{$_} = $i++} split(':',$$RECORD[8]);
				$main::previous_format_string = $$RECORD[8];
			}

			my @nor_geno = split(':',$$RECORD[9]);

			if($nor_geno[$main::previous_format_hash->{'PP'}] + $nor_geno[$main::previous_format_hash->{'NP'}] > 0) {
				return $FAIL;
			}
		}
		return $PASS;
	}
},

{
	tag  => 'INFO/LEN',
	name => 'F003',
	desc => 'Tum low call count strand bias check',
	test => sub {
#		if((pindelVariant.getpMtPos() >= 3) || (pindelVariant.getpMtNeg() >= 3)){
#			ret = Boolean.TRUE;
#		}
#
#		if( pindelVariant.getpMtPos() >= 2 && pindelVariant.getpMtNeg() >= 2){
#			ret = Boolean.TRUE;
#		}

		### HACK Dirty dirty dirty...... done to try and cut down the number of times I have to parse the FORMAT string I am storing it as a global variable.
		if($$RECORD[8] ne $main::previous_format_string){
			my @geno_formats = split(':',$$RECORD[8]);
			my $i = 0;
			map {$main::previous_format_hash->{$_} = $i++} split(':',$$RECORD[8]);
			$main::previous_format_string = $$RECORD[8];
		}

		my @tum_geno = split(':',$$RECORD[10]);
		if(($tum_geno[$main::previous_format_hash->{'PP'}] >= 3 || $tum_geno[$main::previous_format_hash->{'NP'}] >= 3)){
			return $PASS;
		}

		if(($tum_geno[$main::previous_format_hash->{'PP'}] >= 2 && $tum_geno[$main::previous_format_hash->{'NP'}] >= 2)){
			return $PASS;
		}

		return $FAIL;
	}
},

{
	tag  => 'INFO/LEN',
	name => 'F004',
	desc => 'Tum medium read depth strand bias check: Calls In 8% Reads Bt Depth 10 And 200 (inclusive)',
	test => sub {
#//		elsif($input->{'D MT'} >= 10 && $input->{'D MT'} < 200) {
#		if(pindelVariant.getRdMt() >= 10  && pindelVariant.getRdMt() < 200 ){
#//		    if($input->{'P MT +'} && $input->{'P MT -'}) {
#			if(pindelVariant.getpMtPos() > 0  && pindelVariant.getpMtNeg() > 0){
#//			    $pass = 1 if($input->{'P MT'} >= $input->{'D MT'} * 0.05);
#			//	System.out.println(pindelVariant.getpMt() + " " + pindelVariant.getRdMt()+ " " +(pindelVariant.getRdMt() * 0.05f));
#				if(pindelVariant.getpMt() >= (pindelVariant.getRdMt() * 0.05f)) ret = Boolean.TRUE;
#			}
#//		    elsif($input->{'P MT +'} && !$input->{'D MT +'}) {
#			else if(pindelVariant.getpMtPos() > 0 && pindelVariant.getRdMtPos() <= 0){
#				ret = Boolean.TRUE;
#			}
#//		    elsif($input->{'P MT +'}) {
#			else if(pindelVariant.getpMtPos() != null && pindelVariant.getpMtPos() > 0 ){
#//			    $pass = 1 if($input->{'P MT +'} >= $input->{'D MT +'} * 0.08);
#				if(pindelVariant.getpMtPos() >= (pindelVariant.getRdMtPos() * 0.08f)) ret = Boolean.TRUE;
#			}
#//		    elsif($input->{'P MT -'} && !$input->{'D MT -'}) {
#			else if(pindelVariant.getpMtNeg() > 0 && pindelVariant.getRdMtNeg() <= 0){
#				ret = Boolean.TRUE;
#			}
#//		    elsif($input->{'P MT -'}) {
#			else if(pindelVariant.getpMtNeg() != null && pindelVariant.getpMtNeg() > 0 ){
#//			    $pass = 1 if($input->{'P MT -'} >= $input->{'D MT -'} * 0.08);
#				if(pindelVariant.getpMtNeg() >= (pindelVariant.getRdMtNeg() * 0.08f)) ret = Boolean.TRUE;
#			}
#		}else{
#			ret = Boolean.TRUE;
#		}

		### HACK Dirty dirty dirty...... done to try and cut down the number of times I have to parse the FORMAT string I am storing it as a global variable.
		if($$RECORD[8] ne $main::previous_format_string){
			my @geno_formats = split(':',$$RECORD[8]);
			my $i = 0;
			map {$main::previous_format_hash->{$_} = $i++} split(':',$$RECORD[8]);
			$main::previous_format_string = $$RECORD[8];
		}

		my $ret = $FAIL;
		my @tum_geno = split(':',$$RECORD[10]);

		my $prd = $tum_geno[$main::previous_format_hash->{'PR'}];
		my $nrd = $tum_geno[$main::previous_format_hash->{'NR'}];
		my $rd = $prd + $nrd;
		my $pp = $tum_geno[$main::previous_format_hash->{'PU'}];
		my $np = $tum_geno[$main::previous_format_hash->{'NU'}];
		my $p = $pp + $np;

		if($rd >= 10 && $rd < 200){

# re written below to make easier to read....
#			if($pp > 0 && $np > 0){
#				$ret = $PASS if($p >= ($rd * 0.05));
#			}elsif($pp && !$prd){
#				$ret = $PASS;
#			}elsif($pp){
#				$ret = $PASS if($pp >= ($prd * 0.08));
#			}elsif($np && !$nrd){
#				$ret = $PASS;
#			}elsif($np){
#				$ret = $PASS if($np >= ($nrd * 0.08));
#			}

			if($pp > 0 && $np > 0){
				$ret = $PASS if($p >= ($rd * 0.05));
			}elsif($pp > 0){

				if($prd){
					$ret = $PASS if($pp >= ($prd * 0.08));
				}else{
					$ret = $PASS;
				}

			}elsif($np > 0){

				if($nrd){
					$ret = $PASS if($np >= ($nrd * 0.08));
				}else{
					$ret = $PASS;
				}

			}

		}else{
			$ret = $PASS;
		}
		return $ret;
	}
},

{
	tag  => 'INFO/LEN',
	name => 'F005',
	desc => 'Tum high read depth strand bias check: Calls In 4% Reads > Depth 200',
	test => sub {
#//		 elsif($input->{'D MT'} >= 200) {
#//			    if($input->{'P MT +'} && $input->{'P MT -'}) {
#//			      $pass = 1 if($input->{'P MT'} >= $input->{'D MT'} * 0.04);
#//			    }
#//			    elsif($input->{'P MT +'} && !$input->{'D MT +'}) {
#//			      $pass = 1;
#//			    }
#//			    elsif($input->{'P MT +'}) {
#//			      $pass = 1 if($input->{'P MT +'} >= $input->{'D MT +'} * 0.04);
#//			    }
#//			    elsif($input->{'P MT -'} && !$input->{'D MT -'}) {
#//			      $pass = 1;
#//			    }
#//			    elsif($input->{'P MT -'}) {
#//			      $pass = 1 if($input->{'P MT -'} >= $input->{'D MT -'} * 0.04);
#//			    }
#//			  }
#//			  else {
#//			    $pass = 1;
#//			  }
#		PindelVariant pindelVariant = getPindelVariant();
#		Boolean ret = Boolean.FALSE;
#
#		if(pindelVariant.getRdMt() >= 200 ){
#			if(pindelVariant.getpMtPos() > 0  && pindelVariant.getpMtNeg() > 0){
#				if(pindelVariant.getpMt() >= (pindelVariant.getRdMt() * 0.04f)) ret = Boolean.TRUE;
#			}
#			else if( pindelVariant.getpMtPos() > 0 && pindelVariant.getRdMtPos() <= 0){
#				ret = Boolean.TRUE;
#			}
#			else if(pindelVariant.getpMtPos() != null && pindelVariant.getpMtPos() > 0 ){
#				if(pindelVariant.getpMtPos() >= (pindelVariant.getRdMtPos() * 0.04f)) ret = Boolean.TRUE;
#			}
#			else if(&& pindelVariant.getpMtNeg() > 0 && pindelVariant.getRdMtNeg() <= 0){
#				ret = Boolean.TRUE;
#			}
#			else if(pindelVariant.getpMtNeg() != null && pindelVariant.getpMtNeg() > 0 ){
#				if(pindelVariant.getpMtNeg() >= (pindelVariant.getRdMtNeg() * 0.04f)) ret = Boolean.TRUE;
#			}
#		}else{
#			ret = Boolean.TRUE;
#		}

		### HACK Dirty dirty dirty...... done to try and cut down the number of times I have to parse the FORMAT string I am storing it as a global variable.
		if($$RECORD[8] ne $main::previous_format_string){
			my @geno_formats = split(':',$$RECORD[8]);
			my $i = 0;
			map {$main::previous_format_hash->{$_} = $i++} split(':',$$RECORD[8]);
			$main::previous_format_string = $$RECORD[8];
		}

		my $ret = $FAIL;
		my @tum_geno = split(':',$$RECORD[10]);

		my $prd = $tum_geno[$main::previous_format_hash->{'PR'}];
		my $nrd = $tum_geno[$main::previous_format_hash->{'NR'}];
		my $rd = $prd + $nrd;
		my $pp = $tum_geno[$main::previous_format_hash->{'PU'}];
		my $np = $tum_geno[$main::previous_format_hash->{'NU'}];
		my $p = $pp + $np;

		if($rd >= 200){

			if($pp > 0 && $np > 0){
				$ret = $PASS if($p >= ($rd * 0.04));
			}elsif($pp > 0){

				if($prd){
					$ret = $PASS if($pp >= ($prd * 0.04));
				}else{
					$ret = $PASS;
				}

			}elsif($np > 0){

				if($nrd){
					$ret = $PASS if($np >= ($nrd * 0.04));
				}else{
					$ret = $PASS;
				}
			}

		}else{
			$ret = $PASS;
		}
		return $ret;
	}

},

{
	tag  => 'INFO/LEN',
	name => 'F006',
	desc => 'Small call excessive repeat check: Fail if Length <= 4 and Repeats > 9',
	test => sub {
#if(pindelVariant.getLength() <= 4){
#			if(pindelVariant.getRepeats() > 9){
#				ret = Boolean.FALSE;
#			}
#		}

		if($MATCH <= 4){
			my ($rep) = $$RECORD[7] =~ /REP=(\d+)/;
			if($rep > 9) {
				return $FAIL;
			}
		}
		return $PASS;
	}
},

{
	tag  => 'INFO/LEN',
	name => 'F007',
	desc => 'Sufficient Normal Depth: If Mt Depth > 5 then Wt > 8% tum depth',
	test => sub {
##		if(pindelVariant.getRdMt() > 5){
#			if(pindelVariant.getRdWt() >= (pindelVariant.getRdMt() * 0.08)){
#				ret = Boolean.TRUE;
#			}
#
#		}

		### HACK Dirty dirty dirty...... done to try and cut down the number of times I have to parse the FORMAT string I am storing it as a global variable.
		if($$RECORD[8] ne $main::previous_format_string){
			my @geno_formats = split(':',$$RECORD[8]);
			my $i = 0;
			map {$main::previous_format_hash->{$_} = $i++} split(':',$$RECORD[8]);
			$main::previous_format_string = $$RECORD[8];
		}

		my @nor_geno = split(':',$$RECORD[9]);
		my @tum_geno = split(':',$$RECORD[10]);

		my $nor_d = $nor_geno[$main::previous_format_hash->{'PR'}] + $nor_geno[$main::previous_format_hash->{'NR'}];
		my $tum_d = $tum_geno[$main::previous_format_hash->{'PR'}] + $tum_geno[$main::previous_format_hash->{'NR'}];

		if($tum_d > 5){
			if($nor_d >= ($tum_d * 0.08)){
				return $PASS;
			}
		}

		return $FAIL;
	}
},

{
	tag  => 'INFO/REP',
	name => 'F008',
	desc => 'Wildtype contamination: Fail when wt reads > 5% mt reads.',
	test => sub {
#if(pindelVariant.getpWt() > (pindelVariant.getpMt() * 0.05)){
#			ret = false;
#		}

		### HACK Dirty dirty dirty...... done to try and cut down the number of times I have to parse the FORMAT string I am storing it as a global variable.
		if($$RECORD[8] ne $main::previous_format_string){
			my @geno_formats = split(':',$$RECORD[8]);
			my $i = 0;
			map {$main::previous_format_hash->{$_} = $i++} split(':',$$RECORD[8]);
			$main::previous_format_string = $$RECORD[8];
		}

		my @nor_geno = split(':',$$RECORD[9]);
		my @tum_geno = split(':',$$RECORD[10]);

		if($nor_geno[$main::previous_format_hash->{'PP'}] + $nor_geno[$main::previous_format_hash->{'NP'}] >
			($tum_geno[$main::previous_format_hash->{'PP'}] + $tum_geno[$main::previous_format_hash->{'NP'}]) * 0.05){
				return $FAIL;

		}
		return $PASS;
	}
},

#{
#	tag  => 'INFO/LEN',
#	name => 'F0092',
#	desc => 'Is coding',
#	test => sub {
#		my $to = $POS+$MATCH-1;
#		my $cmd = 'tabix ' . $ENV{VCF_IS_CODING} . " $CHROM:$POS-$to";
#		my $tabix_results = `$cmd`;
#		error('Problem reading |'. $ENV{VCF_IS_CODING} . '| :') if($?);
#		return $PASS if($tabix_results); ## if ANYTHING is returned then it is in a coding region. Mark as pass.
#		return $FAIL;
#	}
#},
{
	tag  => 'INFO/LEN',
	name => 'F009',
	desc => 'Is coding: Pass when in gene footprint.',
	test => sub {

		### HACK Dirty dirty dirty......
		unless($main::VCF_IS_CODING_TABIX){
			use Tabix;
			$main::VCF_IS_CODING_TABIX = new Tabix(-data => $ENV{VCF_IS_CODING},-index => $ENV{VCF_IS_CODING}.'.tbi');
		}

		my $ret = eval{
			## half open interval based.... i.e. from is zero based to is one based.
			# as vcf POS for indels is the previous base pos is already 0-based
			my $res = $main::VCF_IS_CODING_TABIX->query($CHROM,$POS,($POS+$MATCH));
			return $FAIL if(!defined $res->get); # no valid entries (chromosome not in index) so must FAIL
			return $PASS if($main::VCF_IS_CODING_TABIX->read($res));
			return $FAIL;
		};
		if($@) {
		  die $@;
		}
		return $ret;
	}
},

{
	tag  => 'INFO/LEN',                       # The VCF tag to apply this filter on
	name => 'F010',                       # The filter ID
	desc => "Variant must not exist within the Unmatched Normal Panel",  # Description for the VCF header
	test => sub {

#update PINDEL_VARIANT
#set FLAG_BIT_CODE = FLAG_BIT_CODE - ?
#where id_pindel_run = ?
#and id_variant in (
#	select distinct pv.id_variant
#	from pindel_variant pv, PINDEL_EXCL_MAT PE
#	where pe.data_type = ?
#	and pv.id_pindel_run = ?
#	and pv.VARIANT_TYPE = pe.type
#	and pv.id_sequence = pe.id_sequence
#	and pv.length <= 2
#	and pv.length between pe.length and pe.length_ext
#	and pv.MIN_POSITION between pe.lhs_pos_1 and pe.rhs_pos_1
#	union all
#	select distinct pv.id_variant
#	from pindel_variant pv, PINDEL_EXCL_MAT PE
#	where pe.data_type = ?
#	and pv.id_pindel_run = ?
#	and pv.VARIANT_TYPE = pe.type
#	and pv.id_sequence = pe.id_sequence
#	and pv.length > 2
#	and pv.length between pe.length and pe.length_ext
#	and pv.MIN_POSITION between pe.lhs_pos_20 and pe.rhs_pos_20)
#

		#22	16404839	.	GA	G	.	.	PC=D;RS=16404838;RE=16404857;LEN=1;SM=138;S1=10;S2=203.791;REP=18	PP:NP:PB:NB:PD:ND:PR:NR:PU:NU	1:0:1:0:4:5:4:6:1:1	3:1:4:2:25:20:32:21:18:8

		### HACK Dirty dirty dirty......
		unless($main::VCF_FLAGGING_UNMATCHED_NORMALS_TABIX){
			use Tabix;
			$main::VCF_FLAGGING_UNMATCHED_NORMALS_TABIX = new Tabix(-data => $ENV{VCF_FLAGGING_UNMATCHED_NORMALS},-index => $ENV{VCF_FLAGGING_UNMATCHED_NORMALS}.'.tbi');
		}

		my $length_off = ($MATCH <= 2) ? 1 : 20;

		my ($from) = ";$$RECORD[7]" =~ m/;RS=([^;]+)/;
		my ($to) = ";$$RECORD[7]" =~ m/;RE=([^;]+)/;
		#Range is the bases surrounding a position so need to bump back to the actual repetitive tract (or single pos)
		# but only when REP is > 0
		if(";$$RECORD[7];" !~ m/;REP=0;/) {
			$from++;
			$to--;
		}
		# then apply the range fudging
		$from -= ($length_off + 1); # additional -1 to switch to 0 based
		$to += $length_off;

		my $ret = eval{
			my $res = $main::VCF_FLAGGING_UNMATCHED_NORMALS_TABIX->query($CHROM,$from,$to);

			return $PASS if(!defined $res->get); # no valid entries (chromosome not in index) so must pass

			while(my $line = $main::VCF_FLAGGING_UNMATCHED_NORMALS_TABIX->read($res)){
				return $FAIL;
			}
			return $PASS;
		};
		if($@) {
	    die $@;
		}
		return $ret;
	},
},