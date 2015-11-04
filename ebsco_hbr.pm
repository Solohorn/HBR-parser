########################################################################
# File:         ebsco_hbr.pm
# Summary:      A target parser to be used with SFX OpenURL link resolver
# Purpose:      Send an journal title + article title search to EBSCO as a
#               workaround for resources that do not support persistent links
#
# Adapted from ebsco_am.pm
#
# Copyright (C) 2015 Geoff Sinclair
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.
#
# Author: Geoff Sinclair
# Date:   25 March 2014
# Rev:    0.1
########################################################################
package Parsers::TargetParser::EBSCO_HOST::ebsco_hbr;
use strict ;
use warnings ;
use NetWrap::Escape qw(uri_escape);
use base qw(Parsers::TargetParser) ;
use URI ;
use Data::Dumper;
#==============================================================================
sub _getAny {
#==============================================================================
    my ($this, $ctx_obj, $caller) = @_ ;

	my $svc = $this->{svc} ;
    
	my $url = $this->ebsco_openurl($ctx_obj, $caller) ;

    return ($url) ;
}
#==============================================================================
sub getFullTxt {
#==============================================================================
    my ($this, $ctx_obj) = @_ ;
	return $this->_getAny($ctx_obj) ;
}
#==============================================================================
sub getAbstract {
#==============================================================================
    my ($this, $ctx_obj) = @_ ;
	return $this->_getAny($ctx_obj) ;
}
#==============================================================================
sub getTOC {
#==============================================================================
    my ($this, $ctx_obj) = @_ ;
	return $this->_getAny($ctx_obj, "GT") ;
}
#==============================================================================
sub getCitedJournal {
#==============================================================================
    my ($this, $ctx_obj) = @_ ;
	return $this->_getAny($ctx_obj) ;
}
#==============================================================================
sub  getSelectedFullTxt {
#==============================================================================
    my ($this, $ctx_obj) = @_ ;
	return $this->_getAny($ctx_obj) ;
}
#==============================================================================
sub ebsco_openurl {
#==============================================================================
	my ($this, $ctx_obj, $caller) = @_ ;

	$caller = (defined $caller) ? $caller : '';
	my $jtitle  = $ctx_obj->get('rft.jtitle')  || '' ;
	my $btitle  = $ctx_obj->get('rft.btitle')  || '' ;
	my $atitle  = $ctx_obj->get('rft.atitle')  || '' ;
	my $ctitle  = $ctx_obj->get('confTitle')   || '' ;
	my $stitle  = $ctx_obj->get('@rft.stitle') || '' ;
	my $aulast  = $ctx_obj->get('@rft.aulast') || '' ;
	my $aufirst = $ctx_obj->get('@rft.aufirst')|| '' ;
	my $auinit  = $ctx_obj->get('@rft.auinit') || '' ;
	my $issn = '';
	($ctx_obj->get('rft.issn')) ? ($issn = $ctx_obj->get('rft.issn') ) : ($issn = $ctx_obj->get('rft.eissn') );
	my $eissn   = $ctx_obj->get('rft.eissn')   || '' ;
	my $isbn = '';
	($ctx_obj->get('rft.isbn')) ? ($isbn = $ctx_obj->get('rft.isbn') ) : ($isbn = $ctx_obj->get('rft.eisbn') );
	my $volume  = $ctx_obj->get('rft.volume')  || '' ;
	my $issue   = $ctx_obj->get('rft.issue')   || '' ;
	my $spage   = $ctx_obj->get('rft.spage')   || '' ;
	my $year    = $ctx_obj->get('rft.year')    || '' ;
	my $genre   = $ctx_obj->get('rft.genre')   || '' ;
	my $title   = $ctx_obj->get('rft.title')   || '' ;
	if    ($jtitle) {$title=$jtitle;}
            elsif ($btitle) {$title=$btitle;}
	    elsif ($ctitle) {$title=$ctitle;}
    # parse params
	my $svc          = $this->{svc} ;
	my $host         = $svc->parse_param('linkurl') ;
	my $jkey         = $svc->parse_param('jkey') ;
	my $db_host      = $svc->parse_param('db_host')    ;
	my $ebscohosturl = $svc->parse_param('ebscohosturl') ;
	my $exception    = $svc->parse_param('exception')  || '';
	my $exception1   = $svc->parse_param('exception1') || '';
	my $exception2   = $svc->parse_param('exception2') || '';
	my $uis          = $svc->parse_param('uis')        || '';
	my $eis          = $svc->parse_param('eis')        || '';
	my $shib         = $svc->parse_param('shib')       || '';
	my $customer_id  = $svc->parse_param('customer_id')|| '';
        my $athens_id    = $svc->parse_param('athens_id') || '';
        my $pp_title     = $svc->parse_param('title') || '';
	$issn = ($eis eq '1') ? $eissn : $issn;
	$issn = (length $uis) ? $uis   : $issn;

        warn "title=$title;jtitle=$jtitle";


	if ((length $spage)<4){
            $spage  =~ s/^0+//g;
            }
	$issue  =~ s/^0+//g;
	$volume =~ s/^0+//g;

        $atitle=clean_title ($atitle);
        $atitle = lc($atitle);
    # if there are no conditions for openurl return journal/book level link
    if(($caller eq "GT" || (!$volume && !$issue && !$atitle && ($issn || $title || $jkey)) || $genre =~ /^book/)) {
                my $key_val ;
	    push @$key_val, 'db'    => $db_host ;

            if ($athens_id && $jkey){
                push @$key_val, 'authtype' => "cookie,athens";
                push @$key_val, 'direct'   => 'true';
                push @$key_val, 'jid'      => $jkey;
                push @$key_val, 'site'     => 'ehost-live';
                my $uri = URI->new("$ebscohosturl/login.aspx");
                $uri->query_form($key_val) ;
                return $uri;
            }
	    if(($customer_id) && ($jkey)){
    		push @$key_val, 'authtype' => "cookie,ip,shib";
                push @$key_val, 'custid'   => $customer_id;
	    	push @$key_val, 'direct'   => 'true';
    		push @$key_val, 'jid'      => $jkey;
	    	push @$key_val, 'site'     => 'ehost-live';
    		my $uri = URI->new("$ebscohosturl/login.aspx");
                $uri->query_form($key_val) ;
                return $uri;
		}
    		my $uri = URI->new("$ebscohosturl/direct.asp") ;
		if ($jkey) {
	    	if ($exception eq 'jid') 
                    { push @$key_val, 'jid' => $jkey ;}
    		    else                   
                    { push @$key_val, 'jn' => $jkey ;}
                }
                elsif (($exception eq 'title')&&($title)) {
		    push @$key_val, 'bquery' => "TI $title" ;
		} 
                elsif ($issn) {
		    $issn =~ s/-//;
		    push @$key_val, 'bquery' => "IS $issn" ;
		} 
                elsif ($title) {
		    push @$key_val, 'jid' => $title ;
		}
		push @$key_val, 'scope' => 'site' ;
                push @$key_val, 'authtype' => "cookie,athens" if $athens_id;
		$uri->query_form($key_val) ;
		$uri = construct_shib($uri) if(lc($shib) eq "yes");
		return $uri ;
	}
	
    # set genre if it's empty
	$genre ||= 'article' if $issn ;
	$genre ||= 'book'    if $isbn ;

    # generate date from year, month and day
	my $date = $this->get_date_from_ctx_obj($ctx_obj, [qw( year month day )]);
    if ($date =~ /(\d+)-(\d+)-(\d+)/) {
        $date = sprintf("%4d%02d%02d", $1, $2, $3) ;
    }

    my %f = (
		direct	=> 'true',
		db     => $db_host,
		bquery	=> '(TI+("' . $atitle . '"))+AND+(SO+(' . $jtitle . '))',
		type	=> '1',
		site	=> 'ehost-live',
		scope	=> 'site',
	);
	
        if(($customer_id || $athens_id) && $issn  && ($issue || $exception1) && $spage && $volume){
            if ($customer_id){
                $f{'authtype'} = "cookie,ip,shib";
		$f{'custid'}   = $customer_id;
            }
            else{
                $f{'authtype'} = "cookie,athens";
            }
	        my $uri = URI->new($ebscohosturl . '/login.aspx') ;
		$uri->query_form(%f) ;
                return $uri;
	}
        

        #article level with no issn/issue/volume
        ##change jtitle value in case that jtitle should be different than rft.jtitle
        if ($pp_title){
            $jtitle = $pp_title;
        }
        if ((!$issn || !$issue || !$volume || $exception2 eq 'atitle') && ($atitle)&& ($jtitle) && $year){
        my %q = (
                direct  => "true",
                db      => $db_host,
                bquery  => "(SO (".$jtitle."))AND(DT ".$year.")AND(TI ".$atitle.")",
                type    => "1",
                site    => "ehost-live",
                );
            if ($athens_id){
                $q{'authtype'} = "cookie,athens";
            }
    	    elsif ($customer_id){
                $q{'authtype'} = "cookie,ip,shib";
	        $q{'custid'}   = $customer_id;
            }
            my $uri = URI->new("$ebscohosturl/login.aspx");
	    $uri->query_form(%q) ;
	    return $uri ;
        }
    # generate open URL
	my $uri = URI->new("$ebscohosturl/login.aspx");
	# dump any undefined hash entries
	map { defined $f{$_} or delete $f{$_} } keys %f ;
	$uri->query_form(%f) ;
	
	$uri = construct_shib($uri) if(lc($shib) eq "yes");
	$uri =~ s/%2B/\+/g;
	return $uri ;
}
#=====================================================================================
sub construct_shib {
#=====================================================================================
	my($uri) = @_;
	my $configfile = "$ENV{'SFXCTRL_HOME'}/config/shibboleth.config";
	my $config = Manager::Config->new(file =>$configfile) or warn("Unable to read config file '$configfile'");
	my $config_main = $config->getHashSection('shibboleth');
	my $entityID    = $config_main->{'entityID'} || '';
	return $uri if(!$entityID);
	my $base_shib   = "https://shibboleth.ebscohost.com/Shibboleth.sso/Login";
	$uri  = "$base_shib?providerId=$entityID&target=" . _lcl_uri_escape($uri);
	return $uri ;
}
#=====================================================================================
sub _lcl_uri_escape {
#=====================================================================================
	my($text) = @_;
	$text = uri_escape($text,"\0-\060");
	$text = uri_escape($text,"\72-\100");
	$text = uri_escape($text,"\173-\176");
	return $text;
}
#=====================================================================================
sub clean_title {
#=====================================================================================
        my ($title)=@_;
        $title =~ s/\.\s*$//g;  #remove dot from the atitle postfix
        return '' if(!$title);
        my $clean_title = $title;
        $clean_title =~ s/--/-/g; #replace dashes with hyphens
        $clean_title =~ s/[\?]//g; #remove question marks
        $clean_title =~ s/"//g; #remove quotation marks "
        $clean_title =~ s/\.\.\./ /g; #remove elipses
        $clean_title =~ s/  / /g; #replace double spaces with single spaces
        return $clean_title;
}
1 ;
