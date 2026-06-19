# 《礼往来》Flutter 产品设计文档

> 版本：V1.0  
> 更新时间：2026-06-18  
> 技术路线：Flutter  
> 产品类型：iOS / iPadOS 首发，预留 Android  
> 产品定位：人情往来礼簿、礼金记录、查往来、现场礼台速记

---

## 0. 本版关键调整

本版基于前期「寸心录」方案重构，做了以下调整：

1. **产品名称改为「礼往来」**  
   副标题建议为：**人情往来礼簿**。

2. **开发技术路线改为 Flutter**  
   采用一套 Flutter 代码，优先适配 iPhone + iPad，后续可扩展 Android。

3. **产品定位改为低频刚需工具**  
   不强调每日打开、不强调小组件、不做日常打卡，而是聚焦婚礼、满月、乔迁、白事等关键场景。

4. **新增「礼台模式」作为核心亮点**  
   面向婚礼现场、白事现场、满月宴现场，支持横屏快速记礼，先填姓名和金额，后期补全信息。

5. **iPhone 与 iPad 不做两套 App**  
   采用 Universal App 思路：一套数据、一套逻辑、响应式布局。  
   iPhone 适合随手记、查往来；iPad 适合横屏礼台、整理礼簿、导出年度礼簿。

6. **视觉方向升级为“古风高级感”**  
   不是婚庆大红大紫，不是老年风，而是宣纸、宫红、描金、水墨、留白、宋意字体、册页感的现代新中式设计。

---

# 1. 产品概述

## 1.1 产品名称

**礼往来**

## 1.2 副标题

推荐使用：

> **人情往来礼簿**

备用副标题：

- 人情往来礼金记录
- 婚丧嫁娶礼金记录
- 查往来，回礼更体面

## 1.3 Slogan

推荐：

> **礼有往来，情有分寸。**

备用：

- 查往来，回礼更体面。
- 红白有别，往来有度。
- 婚礼、满月、乔迁、白事，一簿记清。

---

# 2. 产品定位

## 2.1 一句话定位

**礼往来是一款面向中国家庭的人情往来礼簿 App，用来记录婚礼、满月、乔迁、生日、升学、开业、白事等场景下的礼金、礼品、出力和回礼历史。**

## 2.2 产品本质

它不是普通记账软件，而是一本电子化的中式人情礼簿。

核心问题不是“我花了多少钱”，而是：

- 谁曾经给过我礼？
- 我当时收了多少？
- 现在我该回多少才体面？
- 父母家、自己家、岳父母家的礼账如何分开？
- 婚礼现场、白事现场如何快速记账？
- 白事记录如何庄重、私密、避免喜庆视觉？

## 2.3 产品核心价值

### 1. 记得清楚

记录每一笔人情往来，包括现金、礼品、出力。

### 2. 查得快速

通过姓名、关系、事项快速查往来。

### 3. 回得体面

根据历史记录、关系亲疏、事项类型，给出合适的回礼参考。

### 4. 现场好用

婚礼、白事、满月宴等现场可以进入「礼台模式」，快速记录姓名和金额。

### 5. 私密安心

默认本地保存，不依赖服务器。支持导出备份，后续可选云同步。

---

# 3. 目标用户

## 3.1 核心用户

1. **已婚家庭用户**  
   经常需要参加婚礼、满月、乔迁、生日宴、升学宴、白事等场合。

2. **父母辈 / 中年用户**  
   对人情往来敏感，经常需要记“谁家给了多少、以后该回多少”。

3. **三四线城市、县城、乡镇用户**  
   人情往来频繁，礼金记录需求更真实。

4. **家庭账本管理者**  
   一个人负责记录自己家、父母家、岳父母家的人情往来。

5. **婚礼 / 白事现场记账者**  
   需要在现场快速登记来宾姓名和金额，事后再整理补充关系与备注。

---

# 4. 产品边界

## 4.1 要做的事

- 礼金记录
- 礼品记录
- 出力记录
- 收礼 / 回礼记录
- 红榜 / 白榜区分
- 查往来
- 回礼建议
- 礼台模式
- 多账本
- 提醒
- 本地备份
- 年度礼簿导出
- 会员解锁高级能力

## 4.2 不做的事

首版不做：

- 不做完整家庭记账
- 不接银行卡
- 不做社交
- 不做公开社区
- 不做聊天通讯
- 不做复杂黄历系统
- 不做每日打卡
- 不强调小组件
- 不做云端账号系统
- 不做多人实时协作
- 不做大型 AI 助手

---

# 5. 关键使用场景

## 5.1 平时补录

用户参加完婚礼、满月、乔迁后，在手机上打开 App，补录一笔人情记录。

流程：

1. 打开 App
2. 点击「记一笔」
3. 填写姓名、金额、关系、事项
4. 保存记录
5. 后续可在「礼簿」中查看

## 5.2 回礼前查往来

用户准备去参加朋友孩子满月宴，想知道朋友当年给自己随了多少。

流程：

1. 打开 App
2. 点击「查往来」
3. 搜索姓名
4. 查看历史往来
5. App 给出回礼参考金额
6. 用户决定本次金额
7. 记录此次回礼

## 5.3 婚礼现场快速记礼

婚礼现场人多、节奏快，无法完整填写每个字段。

流程：

1. 进入「礼台模式」
2. 选择场合：婚礼
3. 输入来宾姓名
4. 输入金额
5. 点击「记入并继续」
6. 自动清空表单，继续下一位
7. 记录标记为「待补全」
8. 事后批量补充关系和备注

## 5.4 白事现场快速记账

白事场景需要庄重、快速、私密。

流程：

1. 进入「礼台模式」
2. 选择白榜 / 白事
3. 界面切换为黑白灰水墨风
4. 输入姓名和奠仪金额
5. 快速保存
6. 记录仅自己可见，可开启隐私锁

## 5.5 iPad 整理礼簿

用户回家后拿 iPad 横屏整理当天记录。

流程：

1. 打开 iPad 版
2. 左侧选择账本
3. 中间查看当天记录
4. 右侧逐条补充关系、备注、礼品信息
5. 批量标记已补全
6. 导出 PDF 或备份文件

---

# 6. 整体功能结构

## 6.1 一级功能模块

建议底部导航 / 主导航如下：

1. **首页**
2. **礼簿**
3. **记一笔**
4. **查往来**
5. **我的**

iPad 侧边栏可扩展为：

1. 今日往来
2. 礼簿
3. 查往来
4. 礼台模式
5. 待补全
6. 待回礼
7. 年度礼簿
8. 我的

---

# 7. 页面设计

## 7.1 启动页 / 品牌页

### 页面目标

建立「高级古风礼簿」的第一印象。

### 内容

- App 名：礼往来
- 副标题：人情往来礼簿
- Slogan：礼有往来，情有分寸
- 主按钮：入簿
- 底部文案：查往来，回礼更体面

### 视觉

- 宣纸底纹
- 淡墨远山
- 一枚朱红印章
- 金色细线
- 低饱和宫红按钮
- 少量梅枝或云纹，不要拥挤

## 7.2 首页

### 页面目标

展示当前账本的人情概况、近期提醒、快捷入口。

### 页面区块

#### 顶部品牌区

- 礼往来
- 当前账本名
- 日期 / 农历
- 右侧提醒图标

#### 本月往来卡

展示：

- 收礼：6,800
- 回礼：3,200
- 往来结余：+3,600

文案要温和，不要太像财务软件。

推荐用：

- 本月往来
- 收礼
- 回礼
- 往来结余

#### 快捷入口

4 个按钮：

- 查往来
- 记一笔
- 礼台模式
- 礼簿

#### 即将到来

展示：

- 张晓明婚礼，5天后
- 小宝满月，14天后

#### 最近往来

展示最近 5 条记录。

## 7.3 礼簿页

### 页面目标

查看所有记录，支持筛选、搜索、按月份分组。

### 筛选

- 全部
- 收礼
- 回礼
- 喜事
- 白事
- 待补全
- 待回礼

### 列表字段

每条记录展示：

- 姓名
- 关系标签
- 事项类型
- 日期
- 金额
- 收礼 / 回礼状态
- 是否待补全

### 月份分组

示例：

```text
2026年6月
收礼 12,600 元｜回礼 5,800 元
```

## 7.4 记一笔页

### 页面目标

适合平时慢录、完整记录。

### 表单字段

- 收礼 / 回礼
- 喜事 / 白事
- 姓名
- 关系
- 事项类型
- 金额
- 记录方式：现金 / 礼品 / 出力
- 日期
- 备注

### 喜事类型

- 婚礼
- 满月
- 乔迁
- 祝寿
- 升学
- 开业
- 生日
- 其他

### 白事类型

- 吊唁
- 奠仪
- 帛金
- 白事其他

### 记录方式

1. 现金：填写金额。
2. 礼品：填写礼品名称、估算金额。
3. 出力：填写出力事项、估算人情价值。

## 7.5 查往来页

### 页面目标

快速查出与某人的历史往来，并给出回礼参考。

### 页面结构

1. 搜索框  
   提示：搜索姓名、关系或事项。

2. 人物卡  
   显示姓名、关系、最近往来、总记录数。

3. 对联式回礼卡  
   左侧：彼时彼刻，他随我多少。  
   右侧：此时此刻，我回他多少。

4. 回礼建议  
   - 原礼返回
   - 小幅加礼
   - 按关系调整
   - 自定义

5. 历史时间线  
   展示该人物所有往来记录。

## 7.6 往来详情页

### 页面目标

展示某个人或某条记录的完整详情。

### 人物详情

展示：

- 姓名
- 关系
- 总收礼
- 总回礼
- 待回礼参考
- 往来时间线
- 最近一次往来
- 备注

### 记录详情

展示：

- 姓名
- 事项
- 金额
- 日期
- 方向：收礼 / 回礼
- 记录方式：现金 / 礼品 / 出力
- 备注
- 是否待补全

---

# 8. 礼台模式设计

## 8.1 功能定位

**礼台模式是面向婚礼、白事、满月、乔迁等现场场景的快速记礼模式。**

用户只需要填写：

- 姓名
- 金额

就可以快速保存。关系、备注、礼品详情可后续补全。

## 8.2 功能入口

入口建议放在：

1. 首页快捷入口
2. 记一笔页右上角
3. iPad 侧边栏
4. 礼簿页浮动按钮长按菜单

## 8.3 进入前选择

进入礼台模式前先选择：

- 场合：婚礼 / 满月 / 乔迁 / 白事 / 其他
- 模式：收礼 / 回礼
- 账本：我家 / 父母家 / 岳父母家

## 8.4 iPhone 竖屏礼台

适合应急快速记录。

页面结构：

```text
顶部：当前场合 + 今日合计
中部：姓名输入
中部：金额输入
中部：快捷金额按钮
底部：记入并继续
下方：最近 3 条记录
```

## 8.5 iPhone 横屏礼台

适合手机横放在桌面。

布局：

```text
左侧：姓名 + 金额 + 快捷金额
右侧：最近记录 + 今日合计
```

## 8.6 iPad 横屏礼台

这是核心亮点。

布局：

```text
左侧：场合设置 + 今日统计
中间：大输入区
右侧：最近记录 + 撤销 / 编辑
```

### 左侧：礼台信息

显示：

- 当前账本
- 当前场合
- 当前模式
- 今日记录数
- 今日收礼合计
- 待补全数量
- 红榜 / 白榜切换

### 中间：主输入区

字段：

- 来宾姓名
- 礼金金额
- 快捷金额
- 简短备注
- 记入并继续

### 右侧：最近记录

展示最近 10 条：

- 姓名
- 金额
- 时间
- 是否待补全

操作：

- 撤销上一条
- 编辑
- 删除
- 批量补全

## 8.7 保存逻辑

点击「记入并继续」后：

1. 写入本地数据库
2. 标记 `entryMode = quickDesk`
3. 标记 `completionStatus = partial`
4. 清空输入框
5. 焦点回到姓名框
6. 右侧最近记录立即刷新
7. 显示轻提示：已入簿

不要弹大弹窗，避免打断连续录入。

## 8.8 红榜与白榜

### 红榜礼台

适合婚礼、满月、乔迁、祝寿、升学。

视觉：

- 宫红
- 描金
- 祥云暗纹
- 红笺卡片
- 印章反馈

### 白榜礼台

适合白事、吊唁、奠仪。

视觉：

- 墨黑
- 灰白
- 松枝
- 寒梅
- 素纸
- 不使用喜庆红色

文案：

- 今日白榜
- 奠仪金额
- 保存记录
- 所有白榜记录仅自己可见

---

# 9. iPhone / iPad 适配策略

## 9.1 总原则

不做两套 App，不做两个项目。

采用：

> 一套 Flutter 项目 + 一套数据模型 + 一套业务逻辑 + 多套响应式布局。

## 9.2 设备定位

### iPhone

定位：

- 随手记录
- 临时查往来
- 事后补全
- 查看提醒

主要使用竖屏。

### iPad

定位：

- 横屏礼台
- 整理礼簿
- 批量补全
- 年度导出
- 家庭账本管理

主要优化横屏。

## 9.3 响应式断点

建议：

```dart
class AppBreakpoints {
  static const double phoneMax = 699;
  static const double tabletMin = 700;
  static const double desktopLikeMin = 1000;
}
```

布局策略：

| 屏幕 | 布局 |
|---|---|
| < 700 | iPhone 单栏布局 |
| 700 - 999 | iPad 竖屏 / 双栏布局 |
| >= 1000 | iPad 横屏 / 三栏布局 |
| 礼台模式横屏 | 专用 Desk Layout |

## 9.4 普通页面布局

### iPhone

- 底部 Tab
- 单栏内容
- 页面栈跳转

### iPad

- 左侧导航
- 中间列表
- 右侧详情
- 表单使用右侧抽屉或居中大卡片

---

# 10. 古风高级感视觉规范

## 10.1 视觉关键词

- 古风
- 高级
- 克制
- 温润
- 留白
- 宣纸
- 宫红
- 描金
- 水墨
- 册页
- 印章
- 礼帖
- 不俗艳

## 10.2 避免的风格

不要做成：

- 婚庆影楼风
- 大红大紫
- 老年机风
- 低端记账 App
- 财神 / 元宝 / 铜钱堆砌
- 过度国潮
- 复杂纹样堆满页面

## 10.3 主色板

### 红榜色

| 名称 | 色值 | 用途 |
|---|---|---|
| 宫墙红 | `#9E2523` | 主按钮、重要卡片 |
| 胭脂红 | `#7A1818` | 深色标题、渐变 |
| 暖金 | `#C8A060` | 描边、分割、徽章 |
| 宣纸白 | `#F7F0E4` | 背景 |
| 墨黑 | `#24201C` | 正文文字 |
| 朱砂红 | `#B83A32` | 提醒、印章 |

### 白榜色

| 名称 | 色值 | 用途 |
|---|---|---|
| 墨黑 | `#222222` | 主按钮、标题 |
| 松烟灰 | `#4D4D4D` | 辅助文字 |
| 素纸白 | `#F6F3EC` | 背景 |
| 淡灰线 | `#D8D3C8` | 分割线 |
| 冷青灰 | `#9FA3A0` | 标签、图标 |
| 寒梅灰 | `#6F7470` | 白榜点缀 |

## 10.4 字体策略

Flutter 中中文字体要注意授权。建议：

### App 内默认

- 使用系统字体，保证清晰。
- 不在正文大量使用书法字体。

### 品牌标题

可使用自备授权字体或做成 Logo 图片。

### 页面标题

可使用宋体风 / 楷体风的授权字体，但要控制使用范围。

### 正文

使用系统字体。

## 10.5 图标风格

图标采用线性新中式风格。

图标元素：

- 礼簿
- 印章
- 红封
- 毛笔
- 喜字
- 奶瓶
- 屋檐
- 寿桃
- 学士帽
- 松枝
- 白花
- 礼盒
- 握手

## 10.6 动效

### 推荐

- 按钮轻压
- 卡片浮起
- 记录保存时印章轻落
- 红榜 / 白榜柔和过渡
- 礼台模式保存后轻提示
- 页面切换低速淡入

### 不推荐

- 大量翻书动画
- 强粒子
- 复杂烟花
- 频繁音效
- 影响输入效率的动画

---

# 11. 数据模型设计

## 11.1 LedgerBook 账本

```dart
class LedgerBook {
  final String id;
  final String name;
  final String type; // personal, family, parents, custom
  final String themeId;
  final bool isDefault;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## 11.2 Person 人物

```dart
class Person {
  final String id;
  final String ledgerBookId;
  final String name;
  final String? nickname;
  final String relationType;
  final String? relationLabel;
  final String? phone;
  final String? avatar;
  final String? note;
  final DateTime? birthdaySolar;
  final String? birthdayLunar;
  final bool isImportant;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## 11.3 GiftRecord 礼金记录

```dart
class GiftRecord {
  final String id;
  final String ledgerBookId;
  final String personId;

  final String direction; // received, given
  final String eventType; // wedding, baby, moving, birthday, funeral...
  final String eventTone; // red, white
  final String recordMethod; // cash, gift, service

  final int? amount;
  final int? estimatedAmount;
  final String? giftName;
  final String? serviceDescription;

  final DateTime eventDate;
  final String? lunarDate;
  final String? note;

  final bool needReturn;
  final String? returnedRecordId;

  final String entryMode; // normal, quickDesk
  final String completionStatus; // complete, partial
  final String? quickScene;
  final String? tempRelationText;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
}
```

## 11.4 Reminder 提醒

```dart
class Reminder {
  final String id;
  final String ledgerBookId;
  final String? personId;
  final String? relatedRecordId;
  final String type; // event, returnGift, birthday, custom
  final String title;
  final DateTime date;
  final DateTime remindAt;
  final String status; // pending, done, ignored
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## 11.5 GiftTemplate 礼金模板

```dart
class GiftTemplate {
  final String id;
  final String name;
  final String eventType;
  final String? relationType;
  final int defaultAmount;
  final String? noteTemplate;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

---

# 12. Flutter 技术架构

## 12.1 技术原则

1. 优先本地
2. 不依赖服务器
3. 一套代码适配 iPhone / iPad
4. 预留 Android
5. UI 全自定义，不使用默认 Material 风格
6. 数据结构清晰，方便后续迁移
7. 先实现导出备份，再考虑云同步

## 12.2 推荐技术栈

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_riverpod:
  go_router:

  drift:
  sqlite3_flutter_libs:
  path_provider:
  path:

  shared_preferences:
  intl:
  uuid:

  in_app_purchase:
  local_auth:
  flutter_local_notifications:

  pdf:
  printing:
  share_plus:

  fl_chart:
```

说明：

- 状态管理：Riverpod
- 路由：GoRouter
- 本地数据库：Drift + SQLite
- 本地设置：SharedPreferences
- 会员买断：in_app_purchase
- 隐私锁：local_auth
- 本地通知：flutter_local_notifications
- PDF 导出：pdf + printing
- 分享导出：share_plus
- 图表：fl_chart

## 12.3 为什么首版不做云同步

礼往来是低频工具，首版最重要的是：

1. 记录稳定
2. 查询准确
3. 礼台模式流畅
4. 本地备份可靠
5. UI 质感高级

云同步可以第二阶段做。

首版可先提供：

- 本地 SQLite
- 手动导出 JSON
- 导出 CSV
- 导出 PDF
- 本地备份恢复

---

# 13. 项目目录结构

```text
lib/
  main.dart

  app/
    app.dart
    router.dart
    app_bootstrap.dart

  core/
    constants/
      app_breakpoints.dart
      app_constants.dart

    theme/
      app_theme.dart
      app_colors.dart
      app_text_styles.dart
      app_spacing.dart

    widgets/
      antique_page_scaffold.dart
      seal_button.dart
      red_ledger_card.dart
      white_ledger_card.dart
      amount_text.dart
      relation_tag.dart
      empty_state.dart

    utils/
      date_utils.dart
      amount_utils.dart
      lunar_utils.dart

  data/
    database/
      app_database.dart
      tables/
        ledger_books_table.dart
        persons_table.dart
        gift_records_table.dart
        reminders_table.dart
        templates_table.dart

    repositories/
      ledger_book_repository.dart
      person_repository.dart
      gift_record_repository.dart
      reminder_repository.dart
      template_repository.dart

  domain/
    entities/
      ledger_book.dart
      person.dart
      gift_record.dart
      reminder.dart
      gift_template.dart

    services/
      return_gift_advisor.dart
      quick_desk_service.dart
      reminder_scheduler.dart
      export_service.dart
      privacy_service.dart

  features/
    splash/
      splash_page.dart

    home/
      home_page.dart
      home_phone_layout.dart
      home_tablet_layout.dart
      home_controller.dart

    ledger/
      ledger_page.dart
      ledger_phone_layout.dart
      ledger_tablet_layout.dart
      record_row.dart
      record_filter_bar.dart

    add_record/
      add_record_page.dart
      add_record_controller.dart
      occasion_picker.dart
      record_method_picker.dart

    quick_desk/
      quick_desk_page.dart
      quick_desk_phone_portrait.dart
      quick_desk_phone_landscape.dart
      quick_desk_tablet_landscape.dart
      quick_desk_controller.dart

    search_old/
      search_old_page.dart
      search_old_controller.dart
      return_gift_card.dart
      exchange_timeline.dart

    detail/
      person_detail_page.dart
      record_detail_page.dart

    reminder/
      reminder_page.dart
      reminder_controller.dart

    profile/
      profile_page.dart
      profile_controller.dart

    membership/
      paywall_page.dart
      purchase_controller.dart

    export/
      annual_export_page.dart
      annual_export_controller.dart
```

---

# 14. 核心业务服务

## 14.1 ReturnGiftAdvisor

用于回礼建议。

输入：

- 历史记录
- 本次事项
- 关系类型
- 上次金额
- 用户偏好

输出：

- 原礼返回
- 小幅加礼
- 按关系调整
- 自定义建议

## 14.2 QuickDeskService

用于礼台模式连续录入。

职责：

- 快速保存记录
- 标记待补全
- 统计今日记录
- 撤销上一条
- 编辑最近记录
- 批量补全

## 14.3 ReminderScheduler

用于提醒：

- 即将赴宴
- 待回礼
- 生日提醒
- 白事纪念提醒

## 14.4 ExportService

用于导出：

- PDF 年度礼簿
- CSV 表格
- JSON 备份
- 单人往来记录

## 14.5 PrivacyService

用于隐私：

- Face ID / Touch ID
- 隐藏金额
- 白榜记录加密入口
- 后台模糊页面

---

# 15. 会员功能设计

## 15.1 商业模式

建议：

> 免费下载 + Pro 永久买断 + 高级主题包

不建议首发订阅。

原因：

- 低频工具不适合强订阅
- 用户对人情账隐私敏感
- 买断制更符合小而美工具气质
- 转化阻力更低

## 15.2 免费版

免费版包含：

- 单账本
- 50 条记录
- 基础礼簿
- 基础查往来
- 基础记一笔
- 基础礼台模式
- 最近记录查看
- 基础提醒
- 本地保存
- 默认主题

## 15.3 Pro 版

Pro 解锁：

1. 无限记录
2. 无限联系人
3. 多账本
4. 礼台模式批量整理
5. 高级回礼建议
6. 年度礼簿 PDF 导出
7. CSV / JSON 导出
8. 高级筛选
9. 白榜隐私增强
10. Face ID / Touch ID 解锁
11. 高级主题
12. 礼金模板
13. 待补全批量处理
14. iPad 三栏增强
15. 人情脉络图

## 15.4 价格建议

首发：

- Pro 早鸟价：12 元
- Pro 正式价：18 或 30 元

后期：

- 高级主题包：6 元 / 套
- 全主题包：18 元
- 家庭高级版：38 元

## 15.5 付费触发点

建议不要一打开就弹付费。

触发点：

1. 记录超过 40 条
2. 点击导出年度礼簿
3. 创建第二个账本
4. 使用批量补全
5. 打开高级回礼建议
6. 开启 Face ID 隐私锁
7. 使用高级主题
8. iPad 三栏增强提示

## 15.6 会员页文案

标题：

> 礼往来 Pro

主文案：

> 让每一份人情，都有据可循。

权益卡片：

- 无限礼簿记录
- 查往来更省心
- 回礼建议更体面
- 多账本更清楚
- 礼台批量整理
- 年度礼簿导出
- 白榜隐私保护
- 古风高级主题

按钮：

> 永久解锁 Pro

恢复购买：

> 恢复购买

---

# 16. 导出与备份

## 16.1 PDF 年度礼簿

导出内容：

- 封面
- 年度总览
- 月份明细
- 人物明细
- 待回礼清单
- 白榜可选隐藏
- 金额可选隐藏

视觉：

- 宣纸背景
- 红榜标题
- 表格清晰
- 少量水墨装饰
- 不花哨

## 16.2 CSV 导出

适合用户进一步整理或导入 Excel。

字段：

- 日期
- 姓名
- 关系
- 事项
- 收礼 / 回礼
- 金额
- 记录方式
- 备注

## 16.3 JSON 备份

用于 App 内恢复。

包含：

- 账本
- 人物
- 记录
- 提醒
- 模板
- 主题设置

---

# 17. 隐私设计

## 17.1 隐私原则

人情账属于私密数据，必须明确告诉用户：

> 礼往来默认本地保存，不上传服务器。  
> 你可以手动导出备份，也可以自行保存到 iCloud Drive、网盘或电脑。

## 17.2 隐私功能

- App 启动锁
- Face ID / Touch ID
- 隐藏金额
- 后台模糊
- 白榜记录私密提示
- 导出文件二次确认
- 删除账本二次确认

---

# 18. 开发阶段规划

## 18.1 第一阶段：MVP

目标：做出可上架测试的核心版本。

功能：

- 启动页
- 首页
- 礼簿
- 记一笔
- 查往来
- 往来详情
- 礼台模式基础版
- 本地数据库
- 基础提醒
- 我的页
- 免费 / Pro 预埋

暂不做：

- 云同步
- 小组件
- OCR
- AI
- 人情脉络复杂图
- 家庭共享

## 18.2 第二阶段：付费增强

功能：

- Store 内购买断
- 无限记录
- 多账本
- 年度礼簿导出
- 批量补全
- 高级回礼建议
- 高级筛选
- Face ID 隐私锁
- 白榜隐私增强

## 18.3 第三阶段：传播增强

功能：

- iPad 横屏礼台精修
- 人情脉络图
- 高级古风主题
- 年度礼簿美化
- 礼仪小贴士
- Android 版本适配

---

# 19. 首版页面优先级

## P0 必做

1. 首页
2. 礼簿
3. 记一笔
4. 查往来
5. 往来详情
6. 礼台模式
7. 我的
8. 本地数据库

## P1 应做

1. 提醒
2. 多账本
3. 导出备份
4. Pro 买断
5. 隐私锁
6. iPad 横屏优化

## P2 后做

1. 人情脉络
2. 高级主题
3. 年度报告美化
4. OCR 导入
5. 云同步
6. Android 上架

---

# 20. App Store 信息建议

## 20.1 App 名

**礼往来**

## 20.2 副标题

**人情往来礼簿**

## 20.3 关键词

- 礼金记录
- 随礼
- 回礼
- 人情往来
- 礼簿
- 婚礼礼金
- 白事礼金
- 满月礼
- 查往来
- 家庭账本

## 20.4 简介开头

> 礼往来是一款为中国家庭设计的人情往来礼簿。  
> 婚礼、满月、乔迁、白事，谁给了多少、我该回多少，一簿记清。

## 20.5 卖点

- 查往来，回礼更体面
- 红白有别，往来有度
- 婚礼现场快速记礼
- 白事记录庄重私密
- iPad 横屏礼台模式
- 本地保存，安心私密

---

# 21. 最终结论

《礼往来》的核心竞争力不是功能数量，而是三个点：

1. **真实痛点**  
   中国家庭确实需要记录人情往来。

2. **关键场景**  
   婚礼、白事、满月、乔迁现场需要快速记账。

3. **高级古风体验**  
   把冰冷表格变成一本有礼数、有分寸、有质感的电子礼簿。

首版必须聚焦：

- 记一笔
- 查往来
- 礼台模式
- 礼簿列表
- 往来详情
- 本地保存

不要把产品做大，而要把核心场景做精。

最终产品定位：

> **礼往来：一款有古风高级感的人情往来礼簿。**  
> **礼有往来，情有分寸。**
