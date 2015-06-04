---
layout: post
title: "Node Excel Practice"
description: ""
keywords: ""
category: 
tags: []
---

excel的导入导出在一般业务系统里是非常常见的，但是nodejs里并没有成熟的处理excel的库，导入问题不大，稍微复杂的导出就搞不定了

那么，只剩下曲线救国一条路了

## 合理架构

node的优点就不说了，它虽好，但毕竟才出来几年，很多东西都不够完善的，所以在使用这种比较新比较潮的技术的时候，一定要学会扬长避短，不然会很难受

apache的poi是一个不错的库，非常成熟，我从07年就开始用它，

下面是百科的简介


Apache POI 是用Java编写的免费开源的跨平台的 Java API，Apache POI提供API给Java程式对Microsoft Office格式档案读和写的功能。POI为“Poor Obfuscation Implementation”的首字母缩写，意为“可怜的模糊实现”。

Apache POI 是创建和维护操作各种符合Office Open XML（OOXML）标准和微软的OLE 2复合文档格式（OLE2）的Java API。用它可以使用Java读取和创建,修改MS Excel文件.而且,还可以使用Java读取和创建MS Word和MSPowerPoint文件。Apache POI 提供Java操作Excel解决方案（适用于Excel97-2008）。


http://poi.apache.org/

我们需要考虑以下问题：

- 多语言是否合适？
- 分拆功能是否合适？

## 思考

系统小的时候肯定会尽量统一的，系统大了就会有各种鸟了

比如创业初期，可能是rails or express写的东西，但随着业务的壮大，会发现瓶颈的，这个时候你需要扩容

你多加台机器，然后部署一次

可是这样真的好么？

理想的做法是拆分成小模块，就像处理redis缓存一样，业务量大了，就立马多起几个docker实例，非常好运维

而且从职责上看，它也是小而美的代表

既然小了，那么你用什么语言开发还重要么？

比如我的核心系统是expressjs写的，我的下载就用的java写的，我部署了2个，然后nginx处理一下，谁又能看出来差别呢？

而且我的express一定要多起几个实例，而java的可能并发比较少，我没有去浪费资源。


## 分享一个简单的工具类

```
package im.xbm.dlcenter.test;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFDateUtil;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

public class ExcelUtils {
	// 对外提供读取excel文件的接口
	public static List<List<Object>> readExcel(File file) throws IOException {
		String fName = file.getName();
		String extension = fName.lastIndexOf(".") == -1 ? "" : fName
				.substring(fName.lastIndexOf(".") + 1);
		if ("xls".equals(extension)) {// 2003
			System.err.println("读取excel2003文件内容");
			return read2003Excel(file);
		} else if ("xlsx".equals(extension)) {// 2007
			System.err.println("读取excel2007文件内容");
			return read2007Excel(file);
		} else {
			throw new IOException("不支持的文件类型:" + extension);
		}
	}

	/**
	 * 读取2003excel
	 * 
	 * @param file
	 * @return
	 */
	private static List<List<Object>> read2003Excel(File file)
			throws IOException {
		List<List<Object>> dataList = new ArrayList();
		HSSFWorkbook wb = new HSSFWorkbook(new FileInputStream(file));
		HSSFSheet sheet = wb.getSheetAt(0);
		HSSFRow row = null;
		HSSFCell cell = null;
		Object val = null;
		DecimalFormat df = new DecimalFormat("0");// 格式化数字
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");// 格式化日期字符串
		for (int i = sheet.getFirstRowNum(); i < sheet
				.getPhysicalNumberOfRows(); i++) {
			row = sheet.getRow(i);
			if (row == null) {
				continue;
			}
			List<Object> objList = new ArrayList<Object>();
			for (int j = row.getFirstCellNum(); j < row.getLastCellNum(); j++) {
				cell = row.getCell(j);
				if (cell == null) {
					val = null;
					objList.add(val);
					continue;
				}
				switch (cell.getCellType()) {
				case HSSFCell.CELL_TYPE_STRING:
					val = cell.getStringCellValue();
					break;
				case HSSFCell.CELL_TYPE_NUMERIC:
					if ("@".equals(cell.getCellStyle().getDataFormatString())) {
						val = df.format(cell.getNumericCellValue());
					} else if ("General".equals(cell.getCellStyle()
							.getDataFormatString())) {
						val = df.format(cell.getNumericCellValue());
					} else {
						val = sdf.format(HSSFDateUtil.getJavaDate(cell
								.getNumericCellValue()));
					}
					break;
				case HSSFCell.CELL_TYPE_BOOLEAN:
					val = cell.getBooleanCellValue();
					break;
				case HSSFCell.CELL_TYPE_BLANK:
					val = "";
					break;
				default:
					val = cell.toString();
					break;
				}
				objList.add(val);
			}
			dataList.add(objList);
		}
		return dataList;
	}

	/**
	 * 读取excel表头
	 * 
	 * @param file
	 * @return
	 * @throws IOException
	 */
	public static String[] readExcelHead(File file) throws IOException {
		HSSFWorkbook wb = new HSSFWorkbook(new FileInputStream(file));
		HSSFSheet sheet = wb.getSheetAt(0);
		HSSFRow row = null;
		HSSFCell cell = null;
		row = sheet.getRow(0);
		String[] buff = new String[row.getLastCellNum()];
		for (int i = row.getFirstCellNum(); i < row.getLastCellNum(); i++) {
			cell = row.getCell(i);
			buff[i] = cell.getStringCellValue();
		}
		return buff;
	}

	/**
	 * 读取2007excel
	 * 
	 * @param file
	 * @return
	 */

	private static List<List<Object>> read2007Excel(File file)
			throws IOException {
		List<List<Object>> dataList = new ArrayList<List<Object>>();
		XSSFWorkbook xwb = new XSSFWorkbook(new FileInputStream(file));
		XSSFSheet sheet = xwb.getSheetAt(0);
		XSSFRow row = null;
		XSSFCell cell = null;
		Object val = null;
		DecimalFormat df = new DecimalFormat("0");// 格式化数字
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");// 格式化日期字符串
		for (int i = sheet.getFirstRowNum(); i < sheet
				.getPhysicalNumberOfRows(); i++) {
			row = sheet.getRow(i);
			if (row == null) {
				continue;
			}
			List<Object> objList = new ArrayList<Object>();
			for (int j = row.getFirstCellNum(); j < row.getLastCellNum(); j++) {
				cell = row.getCell(j);
				if (cell == null) {
					val = null;
					objList.add(val);
					continue;
				}
				switch (cell.getCellType()) {
				case XSSFCell.CELL_TYPE_STRING:
					val = cell.getStringCellValue();
					break;
				case XSSFCell.CELL_TYPE_NUMERIC:
					if ("@".equals(cell.getCellStyle().getDataFormatString())) {
						val = df.format(cell.getNumericCellValue());
					} else if ("General".equals(cell.getCellStyle()
							.getDataFormatString())) {
						val = df.format(cell.getNumericCellValue());
					} else {
						val = sdf.format(HSSFDateUtil.getJavaDate(cell
								.getNumericCellValue()));
					}
					break;
				case XSSFCell.CELL_TYPE_BOOLEAN:
					val = cell.getBooleanCellValue();
					break;
				case XSSFCell.CELL_TYPE_BLANK:
					val = "";
					break;
				default:
					val = cell.toString();
					break;
				}
				objList.add(val);
			}
			dataList.add(objList);
		}
		return dataList;
	}
}
```

从这个可以看出poi的用法，整体还是比较简单

## 开发知识点

- http://www.eclipse.org/downloads/
- https://github.com/mongodb/mongo-java-driver/

你需要学的是

- 会基本的servlet，写接口（eclipse新建项目的时候，选择dynamic项目）
- 使用eclipse调试开发
- 使用mongodb java driver去操作mongodb
- 使用poi去读取和生成文件
- 使用java处理一下文件路径

这里就不科普了，javaEE的教程一搜一大堆

## 心态

不要排斥其他语言，用好它们的长处才是本事

现在是一个合作的时代


欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)


