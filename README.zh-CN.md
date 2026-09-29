# mu4e-gptel

[English](./README.md) | [**中文**](./README.zh-CN.md)

在 [mu4e](https://www.djcbsoftware.nl/code/mu/mu4e.html) 中直接调用已配置的
[gptel](https://github.com/karthink/gptel)，总结、翻译邮件并起草回复。本项目是一个轻量的
Emacs Lisp 集成层：不额外引入模型 SDK 或 HTTP 客户端，也不保存 API 凭据。

## 功能

- 将当前打开的邮件总结为简体中文。
- 翻译成用户指定的语言。
- 使用原邮件的语言起草回复，并在普通 mu4e 回复缓冲区中打开。
- 通过 gptel 流式接收响应，并在显示结果前收集完整内容。
- 当邮件 plist 中没有 `:body` 正文时，从 mu4e 已渲染的阅读视图提取正文。
- 不会自动发送 AI 生成的回复。

## 环境要求

- Emacs 28.1 或更新版本。
- mu4e 1.12 或更新版本（本插件使用 mu4e 1.12.9 测试）。
- gptel 0.9 或更新版本，并已配置可用的后端和模型。

gptel 配置的服务可以是远程模型或本地模型。本插件不会更改后端、模型或 API 密钥设置。

## 安装

克隆仓库：

```sh
git clone https://github.com/hotalexnet/mu4e-gptel.git ~/code/mu4e-gptel
```

将下面配置加入 `~/.emacs.d/init.el`；如果克隆到了其他目录，请相应修改路径。mu4e
阅读视图加载后，配置会加载本插件并安装快捷键：

```elisp
(with-eval-after-load 'mu4e-view
  (add-to-list 'load-path "~/code/mu4e-gptel")
  (require 'mu4e-gptel)
  (mu4e-gptel-setup))
```

重启 Emacs，或在当前会话中执行这段配置。若不想修改配置文件，也可以在 mu4e
已加载时按 `M-:` 临时执行。

## 使用方法

在 mu4e 中打开一封邮件，然后使用：

| 快捷键 | 命令 | 结果 |
| --- | --- | --- |
| `C-c g s` | `mu4e-gptel-summarize` | 在只读结果缓冲区中显示中文摘要 |
| `C-c g t` | `mu4e-gptel-translate` | 提示目标语言，然后显示译文 |
| `C-c g r` | `mu4e-gptel-draft-reply` | 新建 mu4e 回复草稿并填入生成的内容 |

也可以通过 `M-x` 执行这些命令。翻译目标默认为简体中文。使用生成内容前请先检查和修改；
回复会保留为普通草稿，必须由用户手动发送。

## 邮件范围与隐私

插件会把当前邮件的主题和可读取的正文发送给 gptel 配置的服务。如果 mu4e 的消息元数据中
没有正文，插件会改用已渲染的阅读视图。附件和同一线程中的其他邮件不会被主动包含。

邮件内容被视为不可信输入，并在提示词中明确标记，但这不能保证模型一定能抵御恶意指令，
也不能保证模型输出准确。请求实际发送给哪个服务，由 gptel 后端配置决定。对于不得离开本机
的邮件，除非已确认所配置的服务适合处理这类数据，否则不要使用这些命令。

本插件本身不会发送邮件、保存 API 密钥或更改 gptel 服务配置。

## 测试

在 Emacs 的加载路径中加入 mu4e 和 gptel 后运行 ERT 测试：

```sh
emacs --batch -Q \
  -L /usr/share/emacs/site-lisp/elpa/mu4e-1.12.9 \
  -L "$HOME"/.emacs.d/elpa/gptel-* \
  -L . \
  -l test/mu4e-gptel-test.el \
  -f ert-run-tests-batch-and-exit
```

请按本机安装位置调整 mu4e 和 gptel 路径。可选的真实 API 端到端测试只会向 DeepSeek
发送测试文件中的合成邮件，详见
[`test/mu4e-gptel-live-e2e.el`](./test/mu4e-gptel-live-e2e.el)。该测试需要在
`~/.emacs.d/init.el` 中配置可用的 DeepSeek 密钥，并且需要网络连接。

## 许可证

仓库目前未声明许可证，也未提供许可证文件；在添加许可证前，请勿假定本项目授予了复用权限。
