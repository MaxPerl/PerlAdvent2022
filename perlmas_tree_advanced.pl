#! /usr/bin/perl
use local::lib;
use strict;
use warnings;

use SVG::ChristmasTree; # for creating the christmas tree
use pEFL::Elm;
use pEFL::Evas; # for EVAS_CONSTANTS_


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

_add_color_setting($table,1,{text => "Leaf Color", color => [255,255,0], key => "leaf_colour"});
_add_color_setting($table,2,{text => "Pauble Color", color => [212,175,55], key => "bauble_colour"});
_add_color_setting($table,3,{text => "Pot Color", color => [0,0,255], key => "pot_colour"});

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
	$spinner->indicator_format_set("%1.0f");
	$spinner->value_set($settings{$opts->{key}});
	$spinner->show(); $table->pack($spinner,1,$row,2,1);
	
	$spinner->smart_callback_add("delay,changed" => sub {$settings{$opts->{key}} = int($_[1]->value_get());}, undef);
}

sub _add_color_setting {
	my ($table,$row,$opts) = @_;
	
	my $label = pEFL::Elm::Label->add($table);
	$label->text_set($opts->{text});
	$label->show(); $table->pack($label,0,$row,1,1);

	my $btn = pEFL::Elm::Button->add($table);
	$btn->size_hint_weight_set(EVAS_HINT_EXPAND,0);
	$btn->size_hint_align_set(EVAS_HINT_FILL,0);
	my $bg = pEFL::Elm::Bg->add($btn);
	$bg->color_set( @{ $opts->{color} } );
	$btn->part_content_set("icon", $bg);
	$btn->show(); $table->pack($btn,1,$row,2,1);
	$opts->{btn_bg} = $bg;
	
	$btn->smart_callback_add("clicked",\&set_color,$opts);
}

sub set_color {
	my ($data,$obj,$evinfo) = @_;
	
	my $color_win = pEFL::Elm::Win->add($win, "Settings", ELM_WIN_BASIC);
	$color_win->title_set("Select color");
	$color_win->autodel_set(1);
	$color_win->resize(275,480);
	
	my $bg = pEFL::Elm::Bg->add($color_win);
	$bg->size_hint_weight_set(EVAS_HINT_EXPAND,EVAS_HINT_EXPAND);
	$bg->size_hint_align_set(EVAS_HINT_FILL,EVAS_HINT_FILL);
	$bg->show(); $color_win->resize_object_add($bg);
	
	my $bx = pEFL::Elm::Box->add($color_win);
	$bx->size_hint_weight_set(EVAS_HINT_EXPAND,EVAS_HINT_EXPAND);
	$color_win->resize_object_add($bx);
	$bx->show();

	my $fr = pEFL::Elm::Frame->add($color_win);
	$fr->size_hint_weight_set(EVAS_HINT_EXPAND,EVAS_HINT_EXPAND);
	$fr->size_hint_align_set(EVAS_HINT_FILL,EVAS_HINT_FILL);
	$fr->text_set("Select color");
	$bx->pack_end($fr);
	$fr->show();

	my $rect = pEFL::Evas::Rectangle->add($color_win->evas_get());
	$fr->part_content_set("default",$rect);
	$rect->color_set(@{ $data->{color} },255);
	$rect->show();

	my $fr2 = pEFL::Elm::Frame->add($color_win);
	$fr2->size_hint_weight_set(1.0,0.5);
	$fr2->size_hint_align_set(EVAS_HINT_FILL,EVAS_HINT_FILL);
	$fr2->text_set("Color Selector");
	$bx->pack_end($fr2);
	$fr2->show();

	my $cs = pEFL::Elm::Colorselector->add($color_win);
	$cs->palette_name_set("painting");
	$cs->size_hint_weight_set(EVAS_HINT_EXPAND,0.0);
	$cs->size_hint_align_set(EVAS_HINT_FILL,0.0);
	$cs->color_set(255,90,18,255);
	$cs->show();
	# TODO: Callbacks
	$fr2->part_content_set("default",$cs);
	
	my $ok_btn = pEFL::Elm::Button->new($bx);
	$ok_btn->text_set("OK");
	$ok_btn->size_hint_weight_set(EVAS_HINT_EXPAND,0);
	$ok_btn->size_hint_align_set(EVAS_HINT_FILL, 0);
	$ok_btn->show(); $bx->pack_end($ok_btn);
	
	my $cancel_btn = pEFL::Elm::Button->new($bx);
	$cancel_btn->text_set("Cancel");
	$cancel_btn->size_hint_weight_set(EVAS_HINT_EXPAND,0);
	$cancel_btn->size_hint_align_set(EVAS_HINT_FILL, 0);
	$cancel_btn->show(); $bx->pack_end($cancel_btn);
	
	# Callbacks
	$cancel_btn->smart_callback_add("clicked", sub { $color_win->del(); }, undef );
	$ok_btn->smart_callback_add("clicked", \&_set_color_cb, [$data, $cs, $color_win]);
	$cs->smart_callback_add("changed", \&_change_color,$rect);
	
	$color_win->show();
}

sub _set_color_cb {
	my ($data, $obj, $evinfo) = @_;
	my $opts = $data->[0];
	my $cs = $data->[1];
	my ($r,$g,$b,$a) = $cs->color_get();
	my $key = $opts->{key};
	$settings{$key} = "rgb($r,$g,$b)";
	$opts->{btn_bg}->color_set($r,$g,$b);
	
	$data->[2]->del();
}

sub _change_color {
	my ($rect, $obj, $evinfo) = @_;
	
	my ($r,$g,$b,$a) = $obj->color_get();
	$rect->color_set($r,$g,$b,$a);
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