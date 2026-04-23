# Todo List

## 已完成

- [x] 后端新增后台工单详情接口，支持返回工单基础信息、用户、分配人、消息时间线和附件。
- [x] 后端补充分配约束，只允许分配给 ACTIVE 的 AGENT / ADMIN。
- [x] 后端补充工单状态流转限制，阻止非法状态变更。
- [x] 后端支持后台回复携带附件 ID，并把附件绑定到对应消息。
- [x] 后端用户侧工单详情返回 message-level attachments。
- [x] 后端用户关闭工单后通知 assigned agent，而不是通知用户自己。
- [x] 后端新增可分配人员接口 `GET /admin/agents`。
- [x] admin-web 新增 Tickets 菜单、列表路由和详情路由。
- [x] admin-web 工单列表支持状态筛选、我的工单、未分配工单、分页展示。
- [x] admin-web 工单详情支持查看详情、消息、附件、公开/内部回复、状态更新。
- [x] admin-web 工单详情支持选择 ACTIVE 的 AGENT / ADMIN 作为分配人。
- [x] Flutter 工单列表支持分页和加载更多。
- [x] Flutter 工单详情改为独立 cubit 管理加载、回复、关闭和错误状态。
- [x] Flutter 回复失败时保留输入内容并展示错误。
- [x] Flutter 关闭工单前增加确认弹窗和可选关闭原因。
- [x] Flutter 通知点击可根据 `ticketId` 跳转到工单详情。
- [x] 验证 `server` 构建通过。
- [x] 验证 `admin-web` 构建通过。
- [x] 验证 `flutter analyze` 通过。
- [x] 后端修复用户回复已关闭工单的问题，禁止用户回复已关闭的工单。
- [x] 验证 CLOSED 工单不能再分配或回复。
- [x] 验证非法状态流转返回明确错误。
- [x] 后端实现工单关键词搜索功能（支持搜索工单号、主题、用户邮箱）。
- [x] 后端实现工单优先级筛选和分类筛选功能。
- [x] 后端实现工单操作历史追踪功能（记录创建、状态变更、分配、回复、关闭等操作）。
- [x] admin-web 工单列表增加关键词搜索 UI（后端已实现）。
- [x] admin-web 工单列表增加优先级筛选和分类筛选 UI（后端已实现）。
- [x] admin-web 工单详情增加操作历史展示 UI（后端已实现）。

## 待完成

- [ ] 启动本地 server、admin-web、Flutter，做一轮真实端到端点击验证。
- [ ] 在 Flutter 创建一条新工单，确认 admin-web 列表能看到。
- [ ] 在 admin-web 分配工单给指定客服，确认状态和分配人刷新正确。
- [ ] 在 admin-web 发送公开回复，确认 Flutter 详情和通知能看到更新。
- [ ] 在 admin-web 发送内部备注，确认 Flutter 用户侧不可见。
- [ ] 在 admin-web 修改工单状态，确认 Flutter 用户侧状态同步正确。
- [ ] 在 Flutter 回复工单，确认 admin-web 详情能看到用户新消息。
- [ ] 在 Flutter 关闭工单，确认 admin-web 详情状态变为 CLOSED，且已分配客服收到通知。
- [ ] 验证旧工单没有附件时，admin-web 和 Flutter 详情页都不会崩溃。
- [ ] 部署最新 server 到服务器并重启服务。
- [ ] 部署或发布最新 admin-web 构建产物。
- [ ] 在服务器环境验证 `GET /v1/admin/agents`、工单详情、分配、回复、改状态接口。

## 可选增强

- [ ] 给 admin-web 工单回复补完整附件上传 UI。
- [ ] 给 Flutter 创建工单和回复工单补附件上传 UI。
- [ ] 给附件增加下载或预览入口，而不是只展示文件名和 MIME 类型。
- [ ] 给通知列表增加分页或加载更多。
- [ ] 给 Flutter 工单详情和通知跳转补更完整的本地化文案，替换当前少量英文按钮文案。
- [ ] 给 admin-web 做路由级 code splitting，降低当前 Vite chunk size warning。
- [ ] 补后端 e2e 测试覆盖：admin agents、ticket detail、assign、reply、status transition。
- [ ] 补 admin-web 关键页面测试：Tickets list、Ticket detail、assign/status/reply mutation。
- [ ] 补 Flutter widget/cubit 测试：ticket list pagination、detail reply failure preserves draft、close confirmation。
