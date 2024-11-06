import json
import boto3
import requests
import os


def handler(event, context):
    print(event)
    # Obtém as informações do evento
    detail = event['detail']
    group_id = detail['requestParameters']['groupId']
    
    # Obtém informações sobre o usuário que realizou a alteração
    user_identity = detail['userIdentity']
    user_arn = user_identity.get('arn')
    user_name = user_identity.get('principalId')

    # Obtém as informações de 'ipPermissions' que está dentro de 'items'
    ip_permissions = detail['requestParameters']['ipPermissions'].get('items', [])
   
    # Inicializa o client de Secrets Manager do Boto3 
    sm = boto3.client('secretsmanager')
    # Busca o valor da secret via Boto3
    webhook_url = sm.get_secret_value(SecretId=os.environ['WEBHOOK_SECRET'])
    webhook_url = json.loads(webhook_url['SecretString'])
    
    # Inicializa o client de EC2 do Boto3 
    ec2 = boto3.client('ec2')

    # Verifica cada permissão de IP adicionada no evento
    for permission in ip_permissions:
        # Verifica se 'permission' é um dicionário antes de tentar acessar seus atributos
        if isinstance(permission, dict):
            ip_protocol = permission.get('ipProtocol')
            from_port = permission.get('fromPort')
            to_port = permission.get('toPort')
            ip_ranges = permission.get('ipRanges', {}).get('items', [])

            # Verifica se a porta 22 (SSH) ou 3389 (RDP) foi autorizada para 0.0.0.0/0
            if (from_port == 22 or from_port == 3389) and to_port == from_port:
                for ip_range in ip_ranges:
                    if ip_range.get('cidrIp') == '0.0.0.0/0':
                        # Printa uma mensagem de quem fez a alteração
                        print(f"Usuário {user_name} ({user_arn}) autorizou a porta {from_port} para 0.0.0.0/0 no Security Group {group_id}. Removendo a regra.")
                        
                        # Remove a regra para portas 22 ou 3389 via Boto3
                        ec2.revoke_security_group_ingress(
                            GroupId=group_id,
                            IpPermissions=[{
                                'FromPort': from_port,
                                'ToPort': to_port,
                                'IpProtocol': ip_protocol,
                                'IpRanges': [{'CidrIp': '0.0.0.0/0'}]
                            }]
                        )
                        # Monta a mensagem para enviar no Slack
                        msg = f"Usuário {user_name} ({user_arn}) autorizou a porta {from_port} para 0.0.0.0/0 no Security Group {group_id}. Removendo a regra."
                        send_notification = requests.post(webhook_url['url'], json={"text": msg})

            # Verifica se 'All Traffic' foi autorizado (protocol -1 significa todos os protocolos)
            elif ip_protocol == '-1':
                for ip_range in ip_ranges:
                    if ip_range.get('cidrIp') == '0.0.0.0/0':
                        # Mensagem de quem fez a alteração
                        print(f"Usuário {user_name} ({user_arn}) autorizou 'All Traffic' para 0.0.0.0/0 no Security Group {group_id}. Removendo a regra.")
                        
                        # Remove a regra de "All Traffic" via Boto3
                        ec2.revoke_security_group_ingress(
                            GroupId=group_id,
                            IpPermissions=[{
                                'IpProtocol': '-1',
                                'IpRanges': [{'CidrIp': '0.0.0.0/0'}]
                            }]
                        )
                        # Monta a mensagem para enviar no Slack
                        msg = f"Usuário {user_name} ({user_arn}) autorizou 'All Traffic' para 0.0.0.0/0 no Security Group {group_id}. Removendo a regra."
                        send_notification = requests.post(webhook_url['url'], json={"text": msg})
        else:
            # Adiciona um log de depuração para entender o que houve de errado no evento
            print(f"Formato inesperado em permission: {json.dumps(permission, indent=2)}")
    
    return {
        'statusCode': 200,
        'body': json.dumps('Lambda executado com sucesso.')
    }
