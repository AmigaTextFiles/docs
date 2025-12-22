foreach $i (129..200){
	$text=chr($i);
	$text=(${text}x40)." ";
	$text=${text}x4;
	print "lcdecho \"$text\"\n";
}
