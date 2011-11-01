#    Copyright (c) 2007 Erland Isaksson (erland_i@hotmail.com)
# 
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
package Plugins::CustomBrowse::Settings;

use strict;
use base qw(Plugins::CustomBrowse::BaseSettings);

use File::Basename;
use File::Next;

use Slim::Utils::Log;
use Slim::Utils::Prefs;
use Slim::Utils::Misc;
use Slim::Utils::Strings;

my $prefs = preferences('plugin.custombrowse');
my $log   = logger('plugin.custombrowse');

my $plugin; # reference to main plugin

sub new {
	my $class = shift;
	$plugin   = shift;

	$class->SUPER::new($plugin,1);
}

sub name {
	return 'PLUGIN_CUSTOMBROWSE';
}

sub page {
	return 'plugins/CustomBrowse/settings/basic.html';
}

sub currentPage {
	return Slim::Utils::Strings::string('PLUGIN_CUSTOMBROWSE_SETTINGS');
}

sub pages {
	my %page = (
		'name' => Slim::Utils::Strings::string('PLUGIN_CUSTOMBROWSE_SETTINGS'),
		'page' => page(),
	);
	my @pages = (\%page);
	return \@pages;
}

sub prefs {
	if($::VERSION lt '7.6') {
	        return ($prefs, qw(menu_directory template_directory context_template_directory image_cache menuname menuinsidebrowse override_trackinfo enable_mixerfunction enable_web_mixerfunction single_web_mixerbutton showmixbeforeexecuting header_value_separator));
	}else {
	        return ($prefs, qw(menu_directory template_directory context_template_directory image_cache menuname menuinsidebrowse override_trackinfo single_web_mixerbutton showmixbeforeexecuting header_value_separator));
	}
}
sub handler {
	my ($class, $client, $paramRef) = @_;
	# TODO: Handle properties attribute
	if ($paramRef->{'saveSettings'}) {
		my $properties = $prefs->get('properties');

		for my $key (keys %$properties) {
			if($paramRef->{'property_value_'.$key} eq '') {
				delete $properties->{$key};
			}else {
				$properties->{$key} = $paramRef->{'property_value_'.$key};
			}
		}
		if($paramRef->{'property_name_new'} ne '' && $paramRef->{'property_value_new'} ne '') {
			my $name = $paramRef->{'property_name_new'};
			if(exists $paramRef->{'property_value_new'}) {
				$properties->{$name} = $paramRef->{'property_value_new'};
			}
		}
		$paramRef->{'prefs'}->{'properties'} = $properties;
	}else {
		$paramRef->{'prefs'}->{'properties'} = $prefs->get('properties');
	}
	my $result = $class->SUPER::handler($client, $paramRef);
	if ($paramRef->{'saveSettings'}) {
		Plugins::CustomBrowse::Plugin::getConfigManager()->initWebAdminMethods();
		Plugins::CustomBrowse::Plugin::getContextConfigManager()->initWebAdminMethods();
		if($prefs->get('override_trackinfo')) {
			Slim::Buttons::Common::addMode('trackinfo',Plugins::CustomBrowse::Plugin::getFunctions(),\&Plugins::CustomBrowse::Plugin::setModeContext);
		}else {
			if(UNIVERSAL::can("Slim::Buttons::TrackInfo","getFunctions")) {
				Slim::Buttons::Common::addMode('trackinfo',Slim::Buttons::TrackInfo::getFunctions(),\&Slim::Buttons::TrackInfo::setMode);
			}else {
				Slim::Buttons::Common::addMode('trackinfo',undef,\&Slim::Buttons::TrackInfo::setMode);
			}
		}
	}	
	return $result;
}

		
1;
