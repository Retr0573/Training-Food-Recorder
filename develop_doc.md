# Develop Doc
## 2025.4.12
1. 下方菜单栏
   在应用底部设计一个菜单栏，可参考微信，上面设计若干个选项，分别是gym，food，my，对应三个主页面

2. gym页面设计
   主要分为三部分
   a. 训练计划 (Training Plan)
   b. 训练计时 (Training Record)
   c. 训练数据 (Training Data)

## 2025.4.13
### 1. 训练计划页面展开设计总览
- 功能概述：该模块用于帮助用户个性化设计、编辑和管理自己的健身训练计划。训练计划结构分为三级：训练主题（Training Theme）、训练项目（Training Item）、训练组（Training Set）。用户可从零开始创建属于自己的训练流程，也可以对既有计划进行修改、复制、或删除。

- 功能结构图（逻辑分层）：
```
训练主题 Training Theme（如：胸部训练）
└── 训练项目 Training Item（如：卧推）
    └── 训练组 Training Set（如：3组，每组10次，60kg）
```
- 核心功能需求
   - 新建训练主题
   用户可创建一个训练主题，输入名称（例如：“肩部增肌计划”）。
  可为训练主题添加封面图（可选）、备注信息（例如“每周2次，持续4周”）。
   - 添加训练项目
  在训练主题下，添加一个或多个训练项目。
  每个训练项目包含：名称（如：卧推、俯卧撑等）；项目说明（可选）
  - 设置训练组（每个训练项目下）
	添加训练组，用户可以自定义每组的以下参数：
	重复次数（Reps）：例如10次
	重量（Weight）：单位 kg
	休息时间（Rest）：例如60秒
	是否热身组（开关选项）
- 编辑与管理
	- 支持长按拖动排序：训练项目排序，每个训练项目下的训练组排序
	- 支持删除某个训练项目或训练组
	- 在编辑训练组时，支持快速复制前一组的参数生成新组（减少重复输入）
	- 支持整个训练主题的重命名、删除
- 数据存储与同步
	本地持久化：存储训练计划结构，选择你认为合适的方式（比如Core Data 或 SQLite，其他也行）

### 2. Feature/Training部分设计
文件目录按照MVVM架构设计
- Model：处理数据和业务逻辑（如网络请求、数据库操作）
- View：负责界面展示和用户交互（不直接处理逻辑）。
- ViewModel：作为 View 和 Model 的桥梁，处理视图所需的逻辑和数据转换。

MVVM 的工作流程：
- View 触发用户操作（如按钮点击） → 通知 ViewModel。
- ViewModel 调用 Model 获取或处理数据（如发起网络请求）。
- Model 返回数据给 ViewModel → ViewModel 转换为适合 View 显示的形式（如日期格式化）。
- ViewModel 通过 数据绑定（如 Swift 中的 @Published + ObservableObject）自动更新 View。

## 2025.4.14
### 1. Theme的数据持久化
TrainingPlanViewModel.swift中使用FileManager

## 2025.4.15
### 1. Item的数据持久化
创建了新的 TrainingThemeViewModel，它：
- 提供了所有必要的操作方法（添加、删除、更新、移动项目）
更新了 TrainingThemeView：
- 使用新的 TrainingThemeViewModel 替代直接使用 TrainingPlanViewModel
- 通过初始化器注入依赖
- 实现了备注编辑功能
- 所有操作都通过 ViewModel 进行

### 2. Set的数据持久化
创建一个 TrainingItemViewModel 来管理训练项目的训练组
然后更新 TrainingItemView 来使用新的 ViewModel

### 3. 持久化方案修改
FileManager -〉 CoreData

## 2025.4.16
### 1. 初始化record view