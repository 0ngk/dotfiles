## Shared Agent Guidance

### Handoff Files

- When reading `test-spec`, `failure-report`, or `bug-report` files, read the `## Summary` block first.
- Read detail sections only when implementation-level context is needed for delegation.

### Repository Exploration

- Before choosing delegation, perform a small read-only sizing pass yourself: inspect any explicitly named path, nearest local guidance, obvious owner tree, and one or two targeted searches when needed.
- Keep that sizing pass narrow. Do not turn it into medium or broad repository exploration, repeated glob/grep/read chains, or cross-subsystem investigation.
- Use the sizing pass to choose the `explore` fanout:
  - Use 0 `explore` agents when the task is trivial or narrow and the relevant 1-2 files are already known.
  - Use 1 `explore` agent when relevant files are uncertain, more than a couple of files may matter, ownership boundaries need checking, or existing patterns must be discovered.
  - Use 2 `explore` agents when there are two independent discovery directions, such as prompt behavior plus configuration wiring, implementation plus tests, or caller plus callee.
  - Use 3 `explore` agents only when the codebase area is large and there are three clearly separable subsystems, concerns, or search directions whose results can be synthesized.
- Split parallel `explore` tasks by subsystem, concern, or search direction. Do not ask multiple `explore` agents to answer the same broad question.
- If delegation is unavailable, unsafe, or clearly adds no value, perform the smallest necessary direct read-only exploration and state that choice when reporting.

### Validation and Testing

- When correctness confidence depends on tests, checks, reproducibility, generated artifacts, schema validation, runtime behavior, or failure triage, default to delegating validation to `tester` when that delegation is available, safe, and feasible.
- Ask `tester` for the smallest safe validation scope that can answer the question. Do not self-delegate if you are already acting as `tester`; validate directly within your contract instead. If validation cannot be delegated or run, state the residual risk instead of implying it passed.

## 自然言語
- あなたはユーザーからの入力に合わせた言語を話します。大抵の場合、それは日本語です。

## 作業
- あなたが作業をする際は、一コミットの粒度に達したら過去のコミットメッセージのスタイルに則りコミットメッセージをconventional commitに則り出力し、作業を一時停止してください。
- コミットメッセージはConventional Commitsに従ってください。
  - type/scopeは英語のConventional Commits形式にしてください。
  - 説明部分は必ず対象リポジトリの既存履歴の言語・文体に合わせてください。
  - 既存履歴で`type: 日本語の説明`が使われている場合、英語の説明文を使わないでください。
  - 例: `docs: 開発方法のREADMEを追加`
  - 悪い例: `docs: add development README`
  - 判断に迷う場合は`git log --oneline -10`を確認し、最も近いスタイルに合わせてください。
- コミット実行は、ユーザーが明示的に依頼または承認した場合のみ行ってください。
- コミット前には必ず`git status`、`git diff`、`git log --oneline -10`を確認してください。
- stage/commitするファイルは作業対象に限定してください。
- 作業が終わっても、元から起動していたサーバープロセスはkillしないでください。

## パッケージマネージャ
- プロジェクトを読み、実際に使用されているパッケージマネージャーを特定してください。

## フォーマット
- プロジェクトで使用されているフォーマッタ（例: Biome）を特定し、その設定に従ってコードをフォーマットしてください。

## Web開発におけるビルドなどのタスク
- `pnpm dev`など、サーバーを起動するコマンドを実行する前に、パッケージファイルやソースコードなどからホストとポート番号を特定し、それを使用してagent-browser skillsでアクセスを試みてください。
- curlコマンドなどで確かめないでください
  - 権限の兼ね合いで失敗します

## GitHub
- GitHubを使用する場合はghコマンドを使用してください

## React
- reactを書く際は以下のスキルを使用してください
  - vercel-react-best-practices
  - vercel-react-view-transitions

## web-design-guidelines
- webデザインに関する行為をする場合はweb-design-guidelinesを使用してください

## writing-guidelines
- ドキュメントなどを書く場合はwriting-guidelinesを使用してください

## PDF
- PDFの中身を読みたい場合は、readツールではなく、pdf_to_imagesツールを必ず使用してください。さもなくば失敗します。

## MCPなど
- context7
  - ライブラリ/APIのドキュメント、コード生成、セットアップや設定手順が必要な際には、明示的に指示しなくても常にContext7 MCPを使用する。
- deepwiki
  - 大規模なコードベースや特定のリポジトリに関する質問がある場合、明示的に指示しなくても常にdeepwikiを使用する。
- codex
  - コードのバグ修正や最適化、リファクタリングが必要な場合やプランを作成した場合、明示的に指示しなくても常にcodexを使用する。
- Web検索
  - 最新情報が必要な場合、明示的に指示しなくても常にWeb検索を使用する。

## Skills
### ui-ux-pro-max
- ui-ux-pro-maxは、ホームディレクトリの`.claude/skills/ui-ux-pro-max`に保存されているスキルです
- `python3`ではなく、`python`コマンドを使用して実行してください
### agent-browser
  - Webフロントエンドに関する変更を行う場合、明示的に指示しなくても常にagents-browserを使用して変更を確認する。
