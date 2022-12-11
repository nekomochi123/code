

// 四角とプラスの図形を重ねたときのずれを測定する
function main() {
    imageDir = getDirectory("choose a image directory: ");

    // 出力の設定
    Plot.create("ALLresults", "distance_pixels", "value");
    Table.renameColumn("X0", "pixels");

	fileNameList = getFileList(imageDir);
	for(i = 0; i < fileNameList.length; i++){
        // 対象のファイルを読み出す
		open(imageDir + list[i]);
		fileName = getTitle();

        // 画像認識しやすいように加工
		selectWindow(fileName);
        convertImage(fileName);

        // データをテーブルに書き込んであげる
        run("Duplicate...", " ");
        duplicatedFileName = getTitle();
        plotPoint(i, fileName, duplicatedFileName);
        applyPlotStyle(i, fileName, duplicatedFileName);

        // 設定したテーブルのカラム名を修正
        padIndex = i * 2
        Table.renameColumn(padIndex,	fileName);
        Table.renameColumn(padIndex + 1,	duplicatedFileName);
	}
}

/// classにまとめられるならまとめる class ImageHelper {}
// 画像を複製して加工することで画像認識しやすくする
function convertImage(fileName) {
    duplicatedImage = duplicateImage(fileName);
    rotateImage(duplicatedImage);
    maskImage(duplicatedImage);

    fileClose(duplicatedImage);
}
function rotateImage(fileName) {
	run("Rotate... ", "angle=45 grid=1 interpolation=Bilinear");
}
function maskImage(fileName) {
	run("Convert to Mask", "");
	run("Invert", "");
}
function duplicateImage(fileName){
    // 画像を複製してwindowを開き、そちらにフォーカスする
	run("Duplicate...", " ");
	return getTitle();
}


/// データをplotしてあげる(クソコメ) classにまとめられるならまとめる class PlotWriteHelper
function plotPoint(index, fileName, duplicatedFileName) {
    setupEntireImageRecognition();

    plotNoRotate(index, fileName);
    plotRotate(index, duplicatedFileName);
}
function setupEntireImageRecognition() {
    run("Set Measurements...", "area mean min center display redirect=None decimal=3");
}
// クソ命名
function plotNoRotate(index, fileName) {
	selectWindow(fileName);
    run("Analyze Particles...", "size=5000.00-10000.00 show=Nothing display exclude composite");
	line_x_start = getResult("XM",0) - 250;
	line_y_start = getResult("YM",0) - 15;
	line_x_end = 500;
	line_y_end = 30;

	makeRectangle(line_x_start, line_y_start, line_x_end, line_y_end);
	roiManager("Add");

    selectProfile(index);
}
// クソ命名
function plotRotate(index, fileName) {
	selectWindow(fileName);
	run("Analyze Particles...", "size=5000.01-10000.00 show=Nothing display exclude composite");
	line_x_start = getResult("XM",0) - 250;
	line_y_start = getResult("YM",0) - 15;
	line_x_end = 500;
	line_y_end = 30;

	run("Rotate... ", "angle=90 grid=1 interpolation=Bilinear");
	makeRectangle(line_x_start, line_y_start, line_x_end, line_y_end);
	roiManager("Add");

    selectProfile(index);
}
function selectProfile(index) {
	roiManager("select", index);
	run("Plot Profile");
}


// classにまとめられるならまとめる class PlotColorHelper
function applyPlotStyle(index, fileName, duplicatedFileName) {
	plotFileName = fileName;
	plotDuplicatedFileName = duplicatedFileName;

    addPlot(index, plotFileName, "black,none,1.0,Line");
    addPlot(index, plotDuplicatedFileName, "red,none,1.0,Line");
	
	Plot.show();
	Plot.showValues();
}
function addPlot(index, plotFileName, styleSettings) {
	dotIndex = lastIndexOf(plotFileName,".");
	plotFileName = "Plot of " + substring(plotFileName,0,dotIndex);
	Plot.addFromPlot(plotFileName, 0);
	Plot.setStyle(index, styleSettings);
}

/// Util class
function fileClose(fileName){
	selectWindow(fileName);
	close();
}



/// if main ///
main();