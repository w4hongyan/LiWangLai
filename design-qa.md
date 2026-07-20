# iPad 横屏页面 Design QA

## Visual truth

- 礼台模式参考：`原型/横屏礼台模式.png`
- 礼簿管理参考：`原型/横屏礼簿管理.png`
- 实现截图：`build/design-qa/ipad-home-menu-final.png`、`build/design-qa/ipad-desk-aligned-final.png`、`build/design-qa/ipad-desk-event-gate-final.png`、`build/design-qa/ipad-ledger-final.png`
- 验收环境：iPad Pro 13-inch (M5) 模拟器，横屏，1376 × 1032 pt（2752 × 2064 px @2x），浅色模式，使用仅在 Debug 启动参数下生成的真实结构演示数据。

参考图包含设备外框，实现图为原生模拟器内容截图；视觉核对按两者的应用内容区域归一化，不把外框差异计为页面偏差。

## Evidence

### Full-page comparison

- iPad 今日页与统一菜单：`build/design-qa/ipad-home-menu-final.png`
- 礼台模式：`build/design-qa/compare-desk-final.png`
- 礼簿管理：`build/design-qa/compare-ledger-final.png`

### Focused comparison

- 礼台录入表单：`build/design-qa/focus-desk-form-final.png`
- 礼簿记录详情：`build/design-qa/focus-ledger-detail.png`

## States and primary interactions checked

- 礼台模式：从今日页进入时必须先选择一场事或新建一场事；未选择前姓名、金额、备注、常用金额和保存按钮均锁定，避免记录写入错误场次。
- 一场事详情：iPad 可通过“进入礼台模式”直接进入，并自动带入当前场次；新建场次保存后会立即选中并解锁录入区。
- 一场事列表：iPad 每张场次卡片提供“默认模式”和“礼台模式”两个按钮；默认模式进入场次详情，礼台模式直接带入所选场次。iPhone 仍通过整张卡片进入详情。
- 礼台数据：姓名/金额/备注输入、常用金额、连续记账、最近记录、今日与当前场次统计均使用 SwiftData 实际数据。
- 连续记账：输入宾客和金额后点击“记入并继续”，记录数由 10 增至 11，输入区恢复到下一笔可录状态。
- 底部导航：iPad 与 iPhone 统一为“今日、礼簿、入簿、人情、我的”；礼台模式改为今日页中的专项入口，退出或切换菜单后回到统一信息架构。
- 礼簿管理：礼簿分组、全部/收礼/送礼筛选、记录选择、详情展示、新增、编辑、删除和导出入口可用。
- 筛选验证：全部 22 条切换到送礼 3 条，再恢复全部 22 条，列表和详情同步更新。
- iPhone：保留原有页面结构和导航，不因 iPad 适配改变。

## Fidelity review

- Typography：沿用项目现有思源宋体资源；标题、金额、辅助信息的层级与参考图一致。
- Spacing and layout：横屏三栏比例、礼台表单节奏、列表密度和详情卡片已按参考图调整；全局底部工具栏与 iPhone 保持一致。
- Alignment：礼台左栏改为与录入区、最近记录一致的完整等高面板；场次信息使用固定标签列、数值列和图标列，统计项采用等分网格。
- Color and tokens：沿用项目米白纸张底色、朱红强调色、深棕正文和淡金分隔线。
- Assets：礼台顶部使用与应用一致的“礼往来”文字 Logo 与印章；右上装饰统一复用各主页面的 `prototype_header_mountain_plum`，并使用相同的 236pt 尺寸、偏移和透明度。
- Copy：礼簿页不显示“已回/未回”；参考图中的“记录回礼”改为“再记一笔”，保持多次收礼与多次送礼都可独立记录的业务语义。

## Comparison history

### Iteration 1

- P1：姓名行被分隔线撑高，破坏表单节奏。已给输入行固定高度并重新对照。
- P2：头部山水图缩放过大，遮挡品牌。已限制图片宽度和透明度。
- P2：中间操作面板没有填满可用高度。已让卡片按三栏容器高度延展。

### Iteration 2

- P2：品牌图使用了带不透明底的资源。已切换为项目中包含印章的透明书法资源。
- P2：礼台按钮前出现一整块空白。已把弹性间距分配到各输入分组之间，使视觉节奏接近参考图。
- 数据状态：`@Query` 更新晚于首次出现时，礼簿选择可能为空。已监听礼簿 ID 变化并自动选中第一本。

### Post-fix evidence

- 最终全页对照：`build/design-qa/compare-desk-final.png`、`build/design-qa/compare-ledger-final.png`
- 最终重点区域对照：`build/design-qa/focus-desk-form-final.png`、`build/design-qa/focus-ledger-detail.png`
- P0：0
- P1：0
- P2：0

## Accepted deviations / P3 polish

- 当前数据模型只有真实的总礼簿、我家场次和送礼记录，因此左栏不伪造多本独立礼簿。
- 参考图的右侧山水覆盖范围更广；实现中收窄并降低透明度，以保证长列表和金额的可读性。
- 演示姓名与金额使用本地 QA 数据，不要求与静态参考图逐字相同。
- 手写签名、录音和视频留言属于后续功能，本轮未加入。

## Verification

- iPad 模拟器最终构建与运行成功。
- 完整测试在单并发宽度下通过：93 passed，0 failed，0 skipped。
- `git diff --check` 无空白错误。

final result: passed
