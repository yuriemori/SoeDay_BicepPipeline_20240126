# SoeDay_BicepPipeline_20240126

# SOEDAY_BICEPPIPELINE プロジェクト

このプロジェクトには、Azure DevOps パイプラインを通じて Bicep を使用して Azure リソースをインフラストラクチャーとしてコード（IaC）でデプロイするための設定が含まれています。

## ファイル概要

- `azure-pipelines.yml`: Azure DevOps で CI/CD プロセスのパイプライン定義を含む。
- `main.bicep`: Azure にデプロイされるインフラストラクチャを定義する Bicep ファイル。
- `.gitignore`: 故意に追跡されないファイルを無視するためのもの。
- `README.md`: プロジェクトの概要とセットアップ指示を提供する。

## azure-pipelines.yml

`azure-pipelines.yml` ファイルは、自動的にトリガーされない CI/CD パイプライン（`trigger: none`）を設定します。このパイプラインは最新の Ubuntu イメージを使用し、デフォルトで `japaneast` Azure リージョンにリソースをデプロイします。

### パイプラインステップ

1. **手動トリガー**: 自動トリガーが設定されていないため、パイプラインは手動で起動されます。
2. **エージェントプール**: パイプラインは最新の Ubuntu イメージを持つエージェント上で実行されます。
3. **変数**: `deploymentDefaultLocation` のようなカスタム変数が定義され、`japaneast` に設定されています。
4. **ジョブ**: Bicep ファイルを Azure リソースマネージャーテンプレートデプロイメントタスクを使用してデプロイするステップを含む単一のジョブがあります。

## main.bicep

`main.bicep` ファイルは、デプロイされる Azure インフラストラクチャを記述しています。これには以下が含まれます：

- リソースのデプロイメントに使用される Azure リージョン。
- App Service Plan と Storage Account の SKU を決定するための環境タイプ（`nonprod` または `prod`）。
- デモンストレーション用に条件付きでデプロイされるデモ Storage Account。
- グローバルに一意である必要があるリソース名に追加する一意の接尾辞。

### コンポーネント

- **App Service Plan**: 非プロダクションとプロダクション用に異なる SKU で構成されます。
- **App Service**: アプリケーションをホストし、HTTPS のみのポリシーを持ち、App Service Plan にリンクされています。
- **Storage Account**: `deployDemoManualsStorageAccount` パラメータに基づいてオプションでデプロイされ、非プロダクションとプロダクション用に異なる冗長オプションを持ちます。

## はじめに

このパイプラインを使用するには：

1. Azure DevOps アカウントとパイプラインを設定するための必要な権限を持っていることを確認してください。
2. このリポジトリを Azure DevOps プロジェクトにクローンします。
3. Azure と認証するための必要なサービス接続を Azure DevOps に作成します。
4. `ServiceConnectionName`、`ResourceGroupName`、`EnvironmentType`、`DeployDemoManualsStorageAccount` などの必要な環境変数を定義します。
5. Azure DevOps ポータルから手動でパイプラインを実行します。

詳細なセットアップガイドとデプロイメント指示については、以下の公式のドキュメントを参照してください。
https://learn.microsoft.com/ja-jp/training/modules/build-first-bicep-deployment-pipeline-using-azure-pipelines/
