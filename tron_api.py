from flask import Flask, jsonify, abort, make_response,request, json, redirect

from tronapi import Tron
from tronapi import HttpProvider
from trx_utils import decode_hex
from eth_abi import decode_abi
full_node = HttpProvider('https://api.shasta.trongrid.io')
solidity_node = HttpProvider('https://api.shasta.trongrid.io')
event_server = HttpProvider('https://api.shasta.trongrid.io')

app = Flask(__name__)

#idet
#private_key = '64f4340246db4752ce4cdf274834702cd37140ba68a036ee8486a0b370914621'


tron = Tron(full_node=full_node,
        solidity_node=solidity_node,
        event_server=event_server)



#########################################################################################################################
#                                                    Start API
#########################################################################################################################
#private_key = '464d87c77a61a1065e3d21e6e6be9cd3aaeb0ce59724a77c5e86cbeed38bd9b7'
#smart_contract_address = '41A498E47E86108C01105DD4397339B459F1FFDFFF'
smart_contract_address = '41157290966C5D65633276C184D110E4C1DC96C577'
default_address = '41FCF23797364C955A23B73F711219FBF5564B2C17'



def getIndexOfGoods():
    a = tron.transaction_builder.trigger_smart_contract(contract_address = smart_contract_address,
                               function_selector = 'getIndexAuctions()',
                               fee_limit=1000000000,
                               call_value=0,
                               parameters=[],
                               issuer_address=default_address
                               )
    a = a['constant_result']
    decodeH = decode_hex(a[0])
    decodeA= decode_abi(('uint256',),decodeH)
    print(decodeA[0])
    return decodeA[0]

#getIndexOfGoods()


@app.route('/getGoods', methods=["POST"])
def getGoods():
    logsOfError=''
    contents=[]
    try:
        indexOfGoods = getIndexOfGoods()
        for i in range(0, indexOfGoods):
            returnContent = tron.transaction_builder.trigger_smart_contract(contract_address = smart_contract_address,
                                function_selector = 'returnContentsAuctions(uint256)',
                                fee_limit=1000000000,
                                call_value=0,
                                parameters=[ {'type': 'int256', 'value': i}],
                                issuer_address=default_address
                                )
            returnContent = returnContent['constant_result']
            decodeH = decode_hex(returnContent[0])
            decodeA= decode_abi(('uint256', 'string', 'uint256', 'string', 'uint256', 'uint256',),decodeH)
            res_data = {"id_goods":decodeA[0], "title":decodeA[1], "price":decodeA[2], "description":decodeA[3], "count":decodeA[4], "commision":decodeA[5]}
            contents.append(res_data)
            print(decodeA)
    except Exception as e:
        logsOfError=logsOfError + str(e)

    return jsonify({'goods': contents, 'logs':logsOfError})
    #return contents



def getIndexOfChecks(account_address):
    a = tron.transaction_builder.trigger_smart_contract(contract_address = smart_contract_address,
                               function_selector = 'getIndexOfChecksAndIsConfirm(address)',
                               fee_limit=1000000000,
                               call_value=0,
                               parameters=[{'type': 'address', 'value': account_address}],
                               issuer_address=account_address
                               )
    a = a['constant_result']
    decodeH = decode_hex(a[0])
    decodeA= decode_abi(('uint256[]',),decodeH)
    print(decodeA[0])
    return decodeA[0]


#need account_address
@app.route('/getChecks', methods=["POST"])
def getChecks():
    logsOfError=''
    data = request.get_json(force=True)
    account_address =  data['account_address']

    indexOfChecks = []
    checks=[]
    try:
        indexOfChecks = getIndexOfChecks(account_address)
        for i in indexOfChecks:
            check = tron.transaction_builder.trigger_smart_contract(contract_address = smart_contract_address,
                                function_selector = 'getChecksOfGoods(address,uint256)',
                                fee_limit=1000000000,
                                call_value=0,
                                parameters=[{'type': 'address', 'value':account_address},{'type': 'int256', 'value': i}],
                                issuer_address=account_address
                                )
            check = check['constant_result']
            decodeH = decode_hex(check[0])
            decodeA= decode_abi(('string[]','uint256[]','uint256[]','uint256[]','address[]','uint256','string','bool','uint256','string','bool',),decodeH)
            print(decodeA)
            res_data = {"nameOfGood":decodeA[0], "amountOfgood":decodeA[1], "price":decodeA[2], "sumPrice":decodeA[3], "addressOfContract":decodeA[4], "id_check":decodeA[5] ,"timestamp":decodeA[6], "status":decodeA[7], "allSumPrice":decodeA[8], "typeOfOp":decodeA[9], "isCanceled":decodeA[10]}
            checks.append(res_data)
            #print(decodeA)
    except Exception as e:
        logsOfError = logsOfError+str(e)
    return jsonify({'checks': checks, 'logs':logsOfError})


def getAddressOfgoods(account_address):
    addresses = tron.transaction_builder.trigger_smart_contract(contract_address = smart_contract_address,
                               function_selector = 'getAddressOfGoodFromWallet(address)',
                               fee_limit=1000000000,
                               call_value=0,
                               parameters=[{'type': 'address', 'value':account_address}],
                               issuer_address=account_address
                               )
    addresses = addresses['constant_result']
    decodeH = decode_hex(addresses[0])
    decodeA= decode_abi(('uint256[]',),decodeH)
    print("----------------------------------------------------")
    print(decodeA)
    return decodeA[0]

#need account_address
@app.route('/getWallet', methods=["POST"])
def getWallet():
    logsOfError=''
    data = request.get_json(force=True)
    account_address =  data['account_address']

    good_addresses = []
    wallets=[]
    try:
        good_addresses = getAddressOfgoods(account_address)
        for i in good_addresses:
            wallet = tron.transaction_builder.trigger_smart_contract(contract_address = smart_contract_address,
                                function_selector = 'getWalletOfGood_array(address,uint256)',
                                fee_limit=1000000000,
                                call_value=0,
                                parameters=[{'type': 'address', 'value':account_address},{'type': 'int256', 'value':i}],
                                issuer_address=account_address
                                )
            wallet = wallet['constant_result']
            decodeH = decode_hex(wallet[0])
            decodeA= decode_abi(('string','uint256','uint256','uint256','uint256',),decodeH)
            res_data = {"nameOfGood":decodeA[0], "amountOfGood":decodeA[1], "price":decodeA[2], "addressOfGood":decodeA[3], "commission":decodeA[4]}
            wallets.append(res_data)
            #print(decodeA)
    except Exception as e:
        logsOfError = logsOfError + str(e)
    return jsonify({'wallets': wallets, 'logs':logsOfError})



@app.route('/purchaseGoods', methods=["POST"])
def buyGoods():
    id_goods =[]
    amounts_goods=[]
    logsOfError=''
    

    data = request.get_json(force=True)
    account_address =  data['account_address']
    private_key =  data['privateKey']
    id_goods = data['id_goods']
    amounts_goods = data['amounts_goods']
    timestamp = data['timestamp']
    
    
    try:
        trigger = tron.transaction_builder.trigger_smart_contract(contract_address = smart_contract_address,
                                function_selector = 'placeBidBox(uint256[],uint256[],string)', #без пробелов!
                                fee_limit=1000000000,
                                call_value=0,
                                parameters=[{'type':'int256[]','value':id_goods},{'type': 'int256[]','value':amounts_goods},{'type':'string','value':timestamp}],
                                issuer_address=account_address
                                )

        tron.private_key = private_key
        transaction = trigger['transaction']
        signed1_tx = tron.trx.sign(transaction,True,False)
        e = tron.trx.broadcast(signed1_tx)
    except Exception as e:
        logsOfError = logsOfError + str(e)
    return jsonify({'txID':e['txid'], 'logs':logsOfError})

@app.route('/confirmGoods', methods=["POST"])
def confirmGoods():
    id_goods=[]
    logsOfError=''

    data = request.get_json(force=True)
    account_address =  data['account_address']
    private_key =  data['privateKey']
    id_goods = data['id_goods']
    id_check = data['id_check']
    
    try:
        trigger = tron.transaction_builder.trigger_smart_contract(contract_address = smart_contract_address,
                                function_selector = 'finalizeBox(uint256[],uint256)', #без пробелов!
                                fee_limit=1000000000,
                                call_value=0,
                                parameters=[{'type':'int256[]','value':id_goods},{'type': 'int256','value':id_check}],
                                issuer_address=account_address
                                )

        tron.private_key = private_key
        transaction = trigger['transaction']
        signed1_tx = tron.trx.sign(transaction,True,False)
        e = tron.trx.broadcast(signed1_tx)
    except Exception as e:
        logsOfError = logsOfError + str(e)
    return jsonify({'txID':e['txid'], 'logs':logsOfError})


@app.route('/saleOfGoods', methods=["POST"])
def saleOfGoods():
    amounts=[]
    id_goods=[]
    logsOfError=''

    data = request.get_json(force=True)
    account_address =  data['account_address']
    private_key =  data['privateKey']
    id_goods = data['id_goods']
    amounts = data['amounts_goods']
    timestamp = data['timestamp']
    
    try:
        trigger = tron.transaction_builder.trigger_smart_contract(contract_address = smart_contract_address,
                                function_selector = 'saleOfGoodsBox(uint256[],uint256[],string)', #без пробелов!
                                fee_limit=1000000000,
                                call_value=0,
                                parameters=[{'type':'int256[]','value':amounts},{'type': 'int256[]','value':id_goods},{'type': 'string','value':timestamp}],
                                issuer_address=account_address
                                )

        tron.private_key = private_key
        transaction = trigger['transaction']
        signed1_tx = tron.trx.sign(transaction,True,False)
        e = tron.trx.broadcast(signed1_tx)
    except Exception as e:
        logsOfError = logsOfError +str(e)
    return jsonify({'txID':e['txid'], 'logs': logsOfError})





@app.route('/cancelOfPurchase', methods=["POST"])
def cancelOfPurchase():
    id_goods=[]
    logsOfError=''

    data = request.get_json(force=True)
    account_address =  data['account_address']
    private_key =  data['privateKey']
    id_goods = data['id_goods']
    id_check = data['id_check']
    
    try:
        trigger = tron.transaction_builder.trigger_smart_contract(contract_address = smart_contract_address,
                                function_selector = 'cancelConfirmBox(uint256[],uint256)', #без пробелов!
                                fee_limit=1000000000,
                                call_value=0,
                                parameters=[{'type':'int256[]','value':id_goods},{'type': 'int256','value':id_check}],
                                issuer_address=account_address
                                )

        tron.private_key = private_key
        transaction = trigger['transaction']
        signed1_tx = tron.trx.sign(transaction,True,False)
        e = tron.trx.broadcast(signed1_tx)
    except Exception as e:
        logsOfError = logsOfError + str(e)
    return jsonify({'txID':e['txid'], 'logs':logsOfError})







@app.route('/balanceOfToken', methods=["POST"])
def balanceOfToken():
    logsOfError=''
    data = request.get_json(force=True)
    account_address =  data['account_address']

    try:
        balance = tron.transaction_builder.trigger_smart_contract(contract_address = smart_contract_address,
                                function_selector = 'balanceOf(address)',
                                fee_limit=1000000000,
                                call_value=0,
                                parameters=[{'type': 'address', 'value':account_address}],
                                issuer_address=account_address
                                )
        balance = balance['constant_result']
        decodeH = decode_hex(balance[0])
        decodeA= decode_abi(('uint256',),decodeH)
        print("----------------------------------------------------")
        print(decodeA)
    except Exception as e:
        logsOfError = logsOfError + str(e)
    return jsonify({'balance':str(decodeA[0]/100000000), 'logs':logsOfError})

@app.route('/balanceOfTrx', methods=["POST"])
def balanceOfTrx():
    logsOfError=''
    data = request.get_json(force=True)
    account_address =  data['account_address']

    try:
        balance = tron.trx.get_balance(account_address, is_float=True)
        print(balance)
    except Exception as e:
        logsOfError = logsOfError+str(e)
    return jsonify({'balanceTrx':str(balance), 'logs':logsOfError})



@app.route('/freeze_balance', methods=["POST"])
def freeze_balance():
    logsOfError=''
    data = request.get_json(force=True)
    account_address =  data['account_address']
    private_key = data['privateKey']
    amount = data['amount']
    resource = data['resource'] #bandwith or energy


    try:
        tron.private_key = private_key
        freeze_balance = tron.trx.freeze_balance(amount = amount, resource=resource, account = account_address)
        print(freeze_balance)
    except Exception as e:
        logsOfError = logsOfError+str(e)
    return jsonify({'txid':str(freeze_balance['txid']), 'logs':logsOfError})




@app.route('/unfreeze_balance', methods=["POST"])
def unfreeze_balance():
    logsOfError=''
    data = request.get_json(force=True)
    account_address =  data['account_address']
    private_key = data['privateKey']
    resource = data['resource'] #bandwith or energy


    try:
        tron.private_key = private_key
        unfreeze_balance = tron.trx.unfreeze_balance(resource=resource, account = account_address)
        print(unfreeze_balance)
    except Exception as e:
        logsOfError = logsOfError+str(e)
    return jsonify({'unfreeze_balance':str(unfreeze_balance), 'logs':logsOfError})




@app.route('/create_account', methods=["POST"])
def create_account():
    logsOfError=''

    try:
        
        account = tron.create_account
        print(account)
    except Exception as e:
        logsOfError = logsOfError+str(e)
    return jsonify({'publicKey':str(account.public_key), 'base58':str(account.address.base58), 'hex':str( account.address.hex), 'privateKey':str(account.private_key), 'logs':logsOfError})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8839, threaded=True)
    #app.run(host='178.88.112.200', port=8839, threaded=True)
