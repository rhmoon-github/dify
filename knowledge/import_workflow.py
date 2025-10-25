#!/usr/bin/env python3
"""
外部知识库工作流导入脚本

此脚本用于通过Dify API导入支持外部知识库的工作流。
使用前请确保：
1. 已配置好外部知识库API
2. 已创建外部知识库数据集
3. 已获取有效的API访问令牌
"""

import json
import requests
import yaml
import os
import sys
from typing import Dict, Any, Optional


class DifyWorkflowImporter:
    """Dify工作流导入器"""
    
    def __init__(self, base_url: str, api_token: str):
        """
        初始化导入器
        
        Args:
            base_url: Dify API基础URL，例如: http://localhost:5001
            api_token: API访问令牌
        """
        self.base_url = base_url.rstrip('/')
        self.api_token = api_token
        self.headers = {
            'Authorization': f'Bearer {api_token}',
            'Content-Type': 'application/json'
        }
    
    def create_external_knowledge_api(self, name: str, description: str, 
                                    endpoint: str, api_key: str) -> Optional[str]:
        """
        创建外部知识库API配置
        
        Args:
            name: API配置名称
            description: API配置描述
            endpoint: 外部知识库API端点
            api_key: API密钥
            
        Returns:
            外部知识库API ID，失败时返回None
        """
        url = f"{self.base_url}/console/api/datasets/external"
        
        data = {
            "name": name,
            "description": description,
            "settings": {
                "endpoint": endpoint,
                "api_key": api_key
            }
        }
        
        try:
            response = requests.post(url, headers=self.headers, json=data)
            response.raise_for_status()
            
            result = response.json()
            print(f"✅ 外部知识库API配置创建成功: {result.get('id')}")
            return result.get('id')
            
        except requests.exceptions.RequestException as e:
            print(f"❌ 创建外部知识库API配置失败: {e}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"响应内容: {e.response.text}")
            return None
    
    def create_external_dataset(self, name: str, description: str, 
                              external_knowledge_api_id: str, 
                              external_knowledge_id: str) -> Optional[str]:
        """
        创建外部知识库数据集
        
        Args:
            name: 数据集名称
            description: 数据集描述
            external_knowledge_api_id: 外部知识库API ID
            external_knowledge_id: 外部知识库ID
            
        Returns:
            数据集ID，失败时返回None
        """
        url = f"{self.base_url}/console/api/datasets/external/dataset"
        
        data = {
            "name": name,
            "description": description,
            "external_knowledge_api_id": external_knowledge_api_id,
            "external_knowledge_id": external_knowledge_id,
            "external_retrieval_model": {
                "search_method": "semantic_search",
                "reranking_enable": False,
                "reranking_model": {
                    "reranking_provider_name": "",
                    "reranking_model_name": ""
                },
                "top_k": 5,
                "score_threshold_enabled": False
            }
        }
        
        try:
            response = requests.post(url, headers=self.headers, json=data)
            response.raise_for_status()
            
            result = response.json()
            print(f"✅ 外部知识库数据集创建成功: {result.get('id')}")
            return result.get('id')
            
        except requests.exceptions.RequestException as e:
            print(f"❌ 创建外部知识库数据集失败: {e}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"响应内容: {e.response.text}")
            return None
    
    def import_workflow(self, yaml_file_path: str, 
                       external_dataset_id: str) -> Optional[str]:
        """
        导入工作流
        
        Args:
            yaml_file_path: 工作流YAML文件路径
            external_dataset_id: 外部数据集ID
            
        Returns:
            应用ID，失败时返回None
        """
        # 读取YAML文件
        try:
            with open(yaml_file_path, 'r', encoding='utf-8') as f:
                yaml_content = f.read()
        except FileNotFoundError:
            print(f"❌ 找不到文件: {yaml_file_path}")
            return None
        except Exception as e:
            print(f"❌ 读取文件失败: {e}")
            return None
        
        # 解析YAML并更新数据集ID
        try:
            workflow_data = yaml.safe_load(yaml_content)
            
            # 更新工作流中的数据集ID
            if 'spec' in workflow_data and 'app' in workflow_data['spec']:
                if 'workflow' in workflow_data['spec']['app']:
                    workflow = workflow_data['spec']['app']['workflow']
                    if 'graph' in workflow and 'nodes' in workflow['graph']:
                        for node in workflow['graph']['nodes']:
                            if node.get('type') == 'knowledge-retrieval':
                                node['data']['dataset_ids'] = [external_dataset_id]
                                print(f"✅ 已更新知识检索节点的数据集ID: {external_dataset_id}")
            
            # 重新转换为YAML
            updated_yaml_content = yaml.dump(workflow_data, allow_unicode=True, default_flow_style=False)
            
        except Exception as e:
            print(f"❌ 处理YAML文件失败: {e}")
            return None
        
        # 导入工作流
        url = f"{self.base_url}/console/api/apps/imports"
        
        data = {
            "mode": "yaml-content",
            "yaml_content": updated_yaml_content,
            "name": "外部知识库工作流",
            "description": "支持外部知识库检索的智能问答工作流",
            "icon_type": "emoji",
            "icon": "🤖",
            "icon_background": "#FFEAD5"
        }
        
        try:
            response = requests.post(url, headers=self.headers, json=data)
            response.raise_for_status()
            
            result = response.json()
            print(f"✅ 工作流导入成功: {result.get('app_id')}")
            return result.get('app_id')
            
        except requests.exceptions.RequestException as e:
            print(f"❌ 导入工作流失败: {e}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"响应内容: {e.response.text}")
            return None
    
    def test_workflow(self, app_id: str, query: str) -> bool:
        """
        测试工作流
        
        Args:
            app_id: 应用ID
            query: 测试查询
            
        Returns:
            测试是否成功
        """
        url = f"{self.base_url}/v1/workflows/run"
        
        data = {
            "inputs": {
                "query": query,
                "external_knowledge_id": "test_knowledge_id"
            },
            "response_mode": "blocking"
        }
        
        headers = {
            'Authorization': f'Bearer {self.api_token}',
            'Content-Type': 'application/json'
        }
        
        try:
            response = requests.post(url, headers=headers, json=data)
            response.raise_for_status()
            
            result = response.json()
            print(f"✅ 工作流测试成功")
            print(f"查询: {query}")
            print(f"回答: {result.get('data', {}).get('answer', '无回答')}")
            return True
            
        except requests.exceptions.RequestException as e:
            print(f"❌ 工作流测试失败: {e}")
            if hasattr(e, 'response') and e.response is not None:
                print(f"响应内容: {e.response.text}")
            return False


def main():
    """主函数"""
    print("🚀 外部知识库工作流导入工具")
    print("=" * 50)
    
    # 配置参数
    BASE_URL = os.getenv('DIFY_BASE_URL', 'http://localhost:5001')
    API_TOKEN = os.getenv('DIFY_API_TOKEN')
    
    if not API_TOKEN:
        print("❌ 请设置环境变量 DIFY_API_TOKEN")
        print("例如: export DIFY_API_TOKEN='your_api_token_here'")
        sys.exit(1)
    
    # 外部知识库配置
    EXTERNAL_API_NAME = "外部知识库API"
    EXTERNAL_API_DESCRIPTION = "用于检索外部知识库的API配置"
    EXTERNAL_API_ENDPOINT = os.getenv('EXTERNAL_API_ENDPOINT', 'https://your-external-api.com')
    EXTERNAL_API_KEY = os.getenv('EXTERNAL_API_KEY')
    
    if not EXTERNAL_API_KEY:
        print("❌ 请设置环境变量 EXTERNAL_API_KEY")
        print("例如: export EXTERNAL_API_KEY='your_api_key_here'")
        sys.exit(1)
    
    EXTERNAL_KNOWLEDGE_ID = os.getenv('EXTERNAL_KNOWLEDGE_ID', 'your_knowledge_id')
    
    # 创建导入器
    importer = DifyWorkflowImporter(BASE_URL, API_TOKEN)
    
    print(f"📡 连接到Dify: {BASE_URL}")
    print(f"🔑 使用API令牌: {API_TOKEN[:10]}...")
    print()
    
    # 步骤1: 创建外部知识库API配置
    print("步骤1: 创建外部知识库API配置")
    external_api_id = importer.create_external_knowledge_api(
        name=EXTERNAL_API_NAME,
        description=EXTERNAL_API_DESCRIPTION,
        endpoint=EXTERNAL_API_ENDPOINT,
        api_key=EXTERNAL_API_KEY
    )
    
    if not external_api_id:
        print("❌ 无法创建外部知识库API配置，退出")
        sys.exit(1)
    
    print()
    
    # 步骤2: 创建外部知识库数据集
    print("步骤2: 创建外部知识库数据集")
    dataset_id = importer.create_external_dataset(
        name="外部知识库数据集",
        description="用于工作流的外部知识库数据集",
        external_knowledge_api_id=external_api_id,
        external_knowledge_id=EXTERNAL_KNOWLEDGE_ID
    )
    
    if not dataset_id:
        print("❌ 无法创建外部知识库数据集，退出")
        sys.exit(1)
    
    print()
    
    # 步骤3: 导入工作流
    print("步骤3: 导入工作流")
    workflow_file = os.path.join(os.path.dirname(__file__), 'external_knowledge_workflow.yaml')
    app_id = importer.import_workflow(workflow_file, dataset_id)
    
    if not app_id:
        print("❌ 无法导入工作流，退出")
        sys.exit(1)
    
    print()
    
    # 步骤4: 测试工作流
    print("步骤4: 测试工作流")
    test_query = "什么是外部知识库？"
    success = importer.test_workflow(app_id, test_query)
    
    if success:
        print()
        print("🎉 外部知识库工作流导入完成！")
        print(f"📱 应用ID: {app_id}")
        print(f"🌐 访问地址: {BASE_URL}/app/{app_id}")
    else:
        print("⚠️ 工作流导入完成，但测试失败")


if __name__ == "__main__":
    main()