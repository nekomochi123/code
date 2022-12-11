//測定マクロ

/////////グローバル変数//////////
var x, y, x1, y1;

//////////////main//////////////



file_name = dir_open();
//Array.print(file_name);


dup = rotate_binary(file_name);
//Array.print(file_name);
//Array.print(dup);


center_point(dup);
//Array.print(x);
//Array.print(x1);
//Array.print(y);
//Array.print(y1);


file_close(dup);
run("ROI Manager...");
line_plot(file_name,dup);

file_close(dup);




///////////////////////////////


function dir_open(){
	openDir = getDirectory("choose a image");		//処理用に開くフォルダの選択
	//showMessage("select save folder");
	//saveDir = getDirectory("choose a directory");	//保存用のファイル選択
	
	list = getFileList(openDir);					//パス名取得
	name = newArray(list.length);
	title = newArray(list.length);
	for(i=0; i<list.length; i++){
		open(openDir+list[i]);						//ファイルを開く
		name[i] = getTitle();						//拡張子前のファイル名取得
		//dotIndex = lastIndexOf(name[i],".");
		//title = substring(name[i],0,dotIndex);	
	}
	
	return name;
	
}


function rotate_binary(file_name){
	file_name_dup = newArray(file_name.length);
	for (i = 0; i<file_name.length; i++) {
		selectWindow(file_name[i]);
		run("Rotate... ", "angle=45 grid=1 interpolation=Bilinear");	// Rotate
		run("Duplicate...", " ");										//duplicate
		file_name_dup[i] = getTitle();									//duplicateのファイル名取得
		run("Convert to Mask", "");										//二値化
		run("Invert", "");												//インバート
	}
	
	return file_name_dup;
	
}



function center_point(dup){
	x = newArray();
	y = newArray();
	x1 = newArray();
	y1 = newArray();
	
	//int xy1 = 0;
	//int xy2 = 0;
	for(i=0; i<dup.length; i++){
		selectWindow(dup[i]);
		run("Set Measurements...", "area mean min center display redirect=None decimal=3");							//出力する値の設定
		run("Analyze Particles...", "size=5000.00-10000.00 show=Nothing display exclude composite");		//Analyze Particlesの処理
		x[i] = getResult("XM",0);
		y[i] = getResult("YM",0);
		
		//print(x[i]);
		//print(y[i]);
		
		run("Clear Results");
		
		selectWindow(dup[i]);
		run("Rotate... ", "angle=90 grid=1 interpolation=Bilinear");
		run("Analyze Particles...", "size=5000.01-10000.00 show=Nothing display exclude composite");		//Analyze Particlesの処理
		x1[i] = getResult("XM",0);
		y1[i] = getResult("YM",0);
		
		run("Clear Results");
		
		
		//print(x1[i]);
		//print(y1[i]);
		
	
	}
	close("Results");
	//Array.print(x);
	//Array.print(y);
}


function line_plot(file_name,dup){
	for (i = 0; i < dup.length; i++) {
		
		line_x1 = x[i] - 250; 					//オフセット
		line_y1 = y[i] - 15;
		
		line_x2 = 500;
		line_y2 = 30;
		
		
		line_x3 = x1[i] - 250; 					//オフセット
		line_y3 = y1[i] - 15;
		
		line_x4 = 500;
		line_y4 = 30;
		
		//print(line_x1);
		//print(line_x2);
		//print(line_x3);
		//print(line_x4);
		
		//named = "dup_plot_" + file_name[i];
		selectWindow(file_name[i]);
		makeRectangle(line_x1, line_y1, line_x2, line_y2);
		roiManager("Add");
		//roiManager("Select", i);
		
		selectWindow(file_name[i]);
		run("Select None");
		run("Duplicate...", " ");
		selectWindow(dup[i]);
		
		run("Rotate... ", "angle=90 grid=1 interpolation=Bilinear");
		makeRectangle(line_x3, line_y3, line_x4, line_y4);
		roiManager("Add");
		
		 
	}
	
	n = 0;
	for (j = 0; j < dup.length; j++) {
		selectWindow(file_name[j]);
		roiManager("select", n);
		run("Plot Profile");
		
		n = n + 1;
		selectWindow(dup[j]);
		roiManager("select", n);
		run("Plot Profile");
		n = n + 1;	
		}
	
		
	file_name_plot = newArray(file_name.length);
	dup_plot = newArray(dup.length);
	
	for (i = 0; i < file_name.length; i++) {
		dotIndex = lastIndexOf(file_name[i],".");
		file_name_plot[i] = substring(file_name[i],0,dotIndex);	
		file_name_plot[i] = "Plot of " + file_name_plot[i];
		
		
		dotIndex = lastIndexOf(dup[i],".");
		dup_plot[i] = substring(dup[i],0,dotIndex);		
		dup_plot[i] = "Plot of " + dup_plot[i];
	}
	//Array.print(file_name_plot);
	//Array.print(dup_plot);
	
	Plot.create("ALLresults", "distance_pixels", "value")
	
	for (l = 0; l < file_name.length; l++) {
		Plot.addFromPlot(file_name_plot[l], 0);
		Plot.setStyle(l, "black,none,1.0,Line");
		
		Plot.addFromPlot(dup_plot[l], 0);
		Plot.setStyle(l, "red,none,1.0,Line");
	}
	
	Plot.show();
	Plot.showValues();
	
	j = 0;
	Table.renameColumn("X0", "pixels")
	for (i = 0; i < file_name.length; i++) {
		
		YY1 = "Y" + j;
		Table.renameColumn(YY1,	file_name[i]);
		j = j + 1;
		YY2 = "Y" + j;
		Table.renameColumn(YY2,	dup[i]);
		j = j + 1;
	}
	
}



function file_close(dup){
	for (i = 0; i < dup.length; i++) {
	selectWindow(dup[i]);
	close();
	}
}

