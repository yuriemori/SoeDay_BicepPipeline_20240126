// Azure App Serviceとストレージアカウントをデプロイするための設定を行います。環境タイプ（nonprodまたはprod）に基づいて、App Service PlanとストレージアカウントのSKUを選択します。

// Azureリソースがデプロイされるリージョンを指定します。
@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

// 環境の種類を指定します。これはnonprodまたはprodでなければなりません。
@description('The type of environment. This must be nonprod or prod.')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

// デモ用のストレージアカウントをデプロイするかどうかを指定します。
@description('Indicates whether to deploy the storage account for demo.')
param deployDemoManualsStorageAccount bool

// グローバルに一意である必要があるリソース名に追加する一意の接尾辞を指定します。
@description('A unique suffix to add to resource names that need to be globally unique.')
@maxLength(13)
param resourceNameSuffix string = uniqueString(resourceGroup().id)

// App Serviceのアプリ名とプラン名を定義します。
var appServiceAppName = 'demo-${resourceNameSuffix}'
var appServicePlanName = 'demo-plan'
var demoManualsStorageAccountName = 'demoweb${resourceNameSuffix}'

// 環境タイプに基づいて各コンポーネントのSKUを定義します。
var environmentConfigurationMap = {
  nonprod: {
    appServicePlan: {
      sku: {
        name: 'F1'
        capacity: 1
      }
    }
    demoManualsStorageAccount: {
      sku: {
        name: 'Standard_LRS'
      }
    }
  }
  prod: {
    appServicePlan: {
      sku: {
        name: 'S1'
        capacity: 2
      }
    }
    demoManualsStorageAccount: {
      sku: {
        name: 'Standard_ZRS'
      }
    }
  }
}

var demoManualsStorageAccountConnectionString = deployDemoManualsStorageAccount ? 'DefaultEndpointsProtocol=https;AccountName=${demoManualsStorageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${demoManualsStorageAccount.listKeys().keys[0].value}' : ''

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: environmentConfigurationMap[environmentType].appServicePlan.sku
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'DemoManualsStorageAccountConnectionString'
          value: demoManualsStorageAccountConnectionString
        }
      ]
    }
  }
}

resource demoManualsStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = if (deployDemoManualsStorageAccount) {
  name: demoManualsStorageAccountName
  location: location
  kind: 'StorageV2'
  sku: environmentConfigurationMap[environmentType].demoManualsStorageAccount.sku
}