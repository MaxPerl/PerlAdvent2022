#! /usr/bin/perl
use local::lib;
use strict;
use warnings;

use pEFL::Elm;
use pEFL::Evas; # for EVAS_CONSTANTS_
use pEFL::PLSide;
use SVG::ChristmasTree;

my %settings = (
	layers => 3,
	width => 1000,
	trunk_length => 100,
	pot_height => 200,
	leaf_colour => 'rgb(9,186,10)',
	bauble_colour => 'rgb(212,175,55)',
	trunk_colour => 'rgb(139,69,19)',
	pot_colour => 'rgb(133,100,69)',
);

pEFL::Elm::init($#ARGV, \@ARGV);
pEFL::Elm::policy_set(ELM_POLICY_QUIT, ELM_POLICY_QUIT_LAST_WINDOW_CLOSED);

my $win = pEFL::Elm::Win->util_standard_add("christmas-tree", "Christmas Tree!");
$win->autodel_set(1);
$win->resize(800,800);

my $frame = pEFL::Elm::Frame->add($win);
_expand_widget($frame);
my $container = pEFL::Elm::Box->add($win);
_expand_widget($container);
$frame->style_set("pad_large");
$frame->content_set($container);
$frame->show(); $win->resize_object_add($frame);

my $viewer = pEFL::Elm::Image->add($container);
_expand_widget($viewer);
$viewer->show(); $container->pack_end($viewer);

my $table = pEFL::Elm::Table->add($container);
$table->padding_set(10,10);
$table->size_hint_weight_set(EVAS_HINT_EXPAND,0);
$table->size_hint_align_set(EVAS_HINT_FILL,0);
$table->show(); $container->pack_end($table);

_add_slider_setting($table, 4, {label => "Width of the tree", min => 700, max => 3000, key => "width"});
_add_slider_setting($table, 5, {label => "Layers", min => 2, max => 8, key => "layers"});
_add_slider_setting($table, 6, {label => "Trunk length", min => 50, max => 300, key => "trunk_length"});
_add_slider_setting($table, 7, {label => "Pot height", min => 100, max => 400, key => "pot_height"});

my $btn = pEFL::Elm::Button->add($container);
$btn->text_set("Create a new Christmas Tree");
$btn->smart_callback_add("clicked",\&create_christmas_tree,$viewer);
$btn->show(); $container->pack_end($btn);

$win->show();

pEFL::Elm::run();
pEFL::Elm::shutdown();

sub _expand_widget {
	my ($widget) = @_;
	$widget->size_hint_weight_set(EVAS_HINT_EXPAND,EVAS_HINT_EXPAND);
	$widget->size_hint_align_set(EVAS_HINT_FILL,EVAS_HINT_FILL);
}

sub _add_slider_setting {
	my ($table,$row,$opts) = @_;
	
	my $label = pEFL::Elm::Label->add($table);
	$label->text_set($opts->{label});
	$label->show(); $table->pack($label,0,$row,1,1);
	
	my $spinner = pEFL::Elm::Slider->add($table);
	$spinner->size_hint_align_set(EVAS_HINT_FILL,0.5);
	$spinner->size_hint_weight_set(EVAS_HINT_EXPAND,0.0);
	$spinner->min_max_set($opts->{min},$opts->{max});
	$spinner->step_set(1);
	#$spinner->indicator_format_set("%1.0f");
	$spinner->value_set($settings{$opts->{key}});
	$spinner->show(); $table->pack($spinner,1,$row,2,1);
	
	$spinner->smart_callback_add("delay,changed" => sub {$settings{$opts->{key}} = int($_[1]->value_get());}, undef);
}

sub create_christmas_tree {
	my ($viewer,$obj,$evinfo) = @_;
			
	my $tree = SVG::ChristmasTree->new(\%settings);
	
	open my $fh, ">", "tree.svg" or die "Could not write to ./tree.svg: $!\n";
	print $fh $tree->as_xml;
	close $fh;
	
	$viewer->file_set(undef,"");
	$viewer->file_set("./tree.svg","");
}