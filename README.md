# 2020 Matlab 期末作业

选择一篇文献，模仿或修改研究，自行制作出 Matlab Psychtoolbox 心理学实验程序，收集一批被试数据并进行统计分析，最后呈交一份报告。

* 所选文献（第10篇）：Aylward, J., Valton, V., Ahn, W. Y., Bond, R. L., Dayan, P., Roiser, J. P., & Robinson, O. J. (2019). Altered learning under uncertainty in unmedicated mood and anxiety disorders. *Nature human behaviour*, 3(10), 1116-1123.
* 成员：GYL HY MYF。

## 闭环设定&协作方式&协作过程

见[讨论区](https://github.com/MYF2000/matlab-final-homework/issues?q=is%3Aissue+is%3Aclosed)以及[项目看板](https://github.com/MYF2000/matlab-final-homework/projects/2)。

## 文件目录说明

* analyses：存放被试数据（包括问卷数据和行为实验数据），以及统计分析代码和统计分析结果。
* reference-paper：存放用于参考的原始研究文献及开源数据及计算模型代码（然而这次受时间精力与能力限制，并未还原强化学习计算模拟研究）。
* task：存放心理学实验程序的代码及素材。

## 实验程序运行说明

打开 Matlab ，将路径切到 task 文件夹，然后输入 `run` 即可。若出现刷新率同步错误，则输入 `run_ss` 其次是 `run_cVRAM` 尝试运行。

⚠️***注意***：

* 此实验程序的编写环境是 Matlab R2019a 以及 Psychtoolbox-3 ，操作系统是 MacOSX 10.15 。
* 收集数据的过程中发现少数人运行不了 Matlab 内置函数 [writecell](https://ww2.mathworks.cn/help/matlab/ref/writecell.html) ，仔细查看官方文档后发现，此函数在版本 2019a 中才建立。由于数据收集工作已完成，不再编写可向下兼容的实验程序。只需把`run.m`（或`run_ss.m`或`run_cVRAM.m`）中含有`writecell`函数的两行代码（建议使用`Ctrl+F`/`CMD+F`来高效检索及跳转）注释掉，程序即可正常运行，然后对于已经生成的变量数据，可以用官方不推荐的旧方式导出（比如`xlswrite`）。

## ChangeLog

* 200630 1230 MYF 更新此文档的细节，以示项目完结。
* 200601 2135 MYF 增加关于 Matlab 内置函数 writecell 的提醒。
* 200530 2240 MYF 修复一些不足，更新常见报错情形的应对方式。 v1.1 。
* 200529 1830 MYF 在 PTB 实验程序编写完成之际，编写说明文档正式版 v1.0 。
* 200508 2230 MYF 尝试性地发布很不完整的说明文档。
