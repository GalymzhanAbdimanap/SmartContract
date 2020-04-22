#https://faucet.metamask.io/     #free 1 ether
#https://faucet.ropsten.be/      #free 1 ether
import web3
from web3 import Web3
web3 = Web3(Web3.HTTPProvider("https://ropsten.infura.io/v3/d69e87bc2ea3413d86e0df7b6324a96f"))

import auctionBoxInstance as auctionBox
import auctionInstance as auction
from flask import Flask, jsonify, abort, make_response,request, json, redirect
app = Flask(__name__)

auctionBox_contract = web3.eth.contract(address=auctionBox.address, abi=auctionBox.abi)


#users{public_address:private_key}
users={
    '0xeBa84a3f7d8d70955bEFF633098D8d6A3a6c18e5':'41054BE58DCF5FB7831F296914BCA90E8F0F97FC2F89339FD9F2E15ED23F340E',
    '0xd621604f3b808a42a65D4eB73E192c1E04b8504c':'53971879E2BC414BD2B9EAACA254C4187DD6971FFC80FAF12FCC37FA6FD96245',
    '0x0F03d30c1b001aaEc0e6b06D033B313cEeBC4A56':'022F8EA970B8322C5E1ADFF60C52E3BB0B5A41AF4F3FB7D6FE069915B785E2A8'
}

def getBalance(address):
    balance = web3.eth.getBalance(address)
    print(balance)
    return balance


#getBalance('0xd621604f3b808a42a65D4eB73E192c1E04b8504c')

def beforeMount_local():
    arr_content=[]
    contract = web3.eth.contract(address=auctionBox.address, abi=auctionBox.abi)
    allContracts = contract.functions.returnAllAuctions().call()
    for i in allContracts:
        selectedAuction = web3.eth.contract(address=i, abi=auction.abi)
        content = selectedAuction.functions.returnContents().call()
        arr_content.append(content)#[[],[]]
    
    #print(arr_content)
    return arr_content

def getWalletOfGoods_local():
    arr_good_balance=[]
    fromAddress = '0xd621604f3b808a42a65D4eB73E192c1E04b8504c'
    auctionList = beforeMount_local()
    for i, el in enumerate(auctionList):
        good_balance = auctionBox_contract.functions.getWalletOfGood_array(fromAddress, auctionList[i][0]).call()
        good_balance_dict = {'nameOfGood':good_balance[0],'amountOfGood':good_balance[1], 'price':good_balance[2], 'addressOfGood':good_balance[3]}
        arr_good_balance.append(good_balance_dict)
    print(arr_good_balance)
    return arr_good_balance

#getWalletOfGoods_local()

@app.route('/getBalanceOf', methods=["POST"])
def getBalanceOf():
    data = request.get_json(force=True)
    fromAddress = data['address']
    contract = web3.eth.contract(address=auctionBox.address, abi=auctionBox.abi)
    token_balance = contract.functions.balanceOf(fromAddress).call()

@app.route('/beforeMount', methods=["POST"])
def beforeMount():
    arr_content=[]
    contract = web3.eth.contract(address=auctionBox.address, abi=auctionBox.abi)
    allContracts = contract.functions.returnAllAuctions().call()
    for i in allContracts:
        selectedAuction = web3.eth.contract(address=i, abi=auction.abi)
        content = selectedAuction.functions.returnContents().call()
        content_dict = {'nameOfGood':content[0], 'price':content[1], 'defenition':content[2], 'amountOfGood':content[3], 'commission':content[4]}
        arr_content.append(content_dict)#[[],[]]
    
    print(arr_content)
    #return arr_content
    return jsonify({'data': arr_content})

#beforeMount()



@app.route('/getWalletOfGoods', methods=["POST"])
def getWalletOfGoods():
    data = request.get_json(force=True)
    fromAddress = data['address_accounts']
    arr_good_balance=[]
    #fromAddress = '0xd621604f3b808a42a65D4eB73E192c1E04b8504c'
    getNameOfgood =  auctionBox_contract.functions.getNameOfGoodFromWallet(fromAddress).call()
    for i, el in enumerate(getNameOfgood):
        good_balance = auctionBox_contract.functions.getWalletOfGood_array(fromAddress, el).call()
        good_balance_dict = {'nameOfGood':good_balance[0],'amountOfGood':good_balance[1], 'price':good_balance[2], 'addressOfGood':good_balance[3]}
        arr_good_balance.append(good_balance_dict)
    print(arr_good_balance)
    #return arr_good_balance
    return jsonify({'good_balance': arr_good_balance})

#getWalletOfGoods('0xd621604f3b808a42a65D4eB73E192c1E04b8504c')

@app.route('/getChecks', methods=["POST"])
def getChecks():
    data = request.get_json(force=True)
    fromAddress = data['address_accounts']
    arr_checks=[]
    #fromAddress = '0xd621604f3b808a42a65D4eB73E192c1E04b8504c'
    good_checks_indexes = auctionBox_contract.functions.getIndexOfChecksAndIsConfirm
    for i, el in enumerate(good_checks_indexes):
        check = auctionBox_contract.functions.getChecksOfGoods(fromAddress, el).call()
        check_dict = {'name':check[0],'amountOfGood':check[1], 'price':check[2], 'sumPrice':check[3], 'addressOfGood':check[4]}
        arr_checks.append(check_dict)
    print(arr_checks)
    #return arr_checks
    return jsonify({'checks': arr_checks})
#getChecks()

@app.route('/handleFinalize', methods=["POST"])
def handleFinalize():
    data = request.get_json(force=True)
    address_auctions = data['address_auction'] #[]
    indexes = data['indexes'] #[]
    fromAddress = data['address_accounts'] 
    
    #fromAddress = '0xd621604f3b808a42a65D4eB73E192c1E04b8504c'
    selectedAuction = web3.eth.contract(address=auctionBox.address, abi=auctionBox.abi)
    nonce = web3.eth.getTransactionCount(fromAddress)
    
    transaction = selectedAuction.functions.finalizeBox(
    address_auctions,
    indexes
    ).buildTransaction({
    'gas': 7000000,
    'gasPrice': web3.toWei('1', 'gwei'),
    'from': fromAddress,
    'nonce': nonce
    }) 
    private_key = users[fromAddress]
    signed_txn = web3.eth.account.signTransaction(transaction, private_key=private_key)
    web3.eth.sendRawTransaction(signed_txn.rawTransaction)

#handleFinalize('0x81803FdAA57e5CD472A037a13BABCfa4632AB33E')
@app.route('/handleSubmit', methods=["POST"])
def handleSubmit():
    data = request.get_json(force=True)
    address_auctions = data['address_auction'] #[]
    amounts = data['amount'] #[]
    fromAddress = data['address_accounts'] 
    
    #fromAddress = '0xd621604f3b808a42a65D4eB73E192c1E04b8504c'
    selectedAuction = web3.eth.contract(address=auctionBox.address, abi=auctionBox.abi)
    nonce = web3.eth.getTransactionCount(fromAddress)

    transaction = selectedAuction.functions.placeBidBox(
    amounts,
    address_auctions,
    fromAddress ).buildTransaction({
    'gas': 7000000,
    'gasPrice': web3.toWei('1', 'gwei'),
    'from': fromAddress,
    'nonce': nonce
    }) 
    private_key = users[fromAddress]
    signed_txn = web3.eth.account.signTransaction(transaction, private_key=private_key)
    web3.eth.sendRawTransaction(signed_txn.rawTransaction)
    #return true

    

#handleSubmit('0xbd8E711c036E44693884D28Bc185fBbb4eBDEbD7', 2, '0xd621604f3b808a42a65D4eB73E192c1E04b8504c')
@app.route('/createAuction', methods=["POST"])
def createAuction():
    data = request.get_json(force=True)
    startPrice = data['startPrice'] 
    title = data['title'] 
    description = data['description']
    count = data['count']
    commission = data['commission']
    fromAddress = data['address_accounts'] 

    gasPrice = web3.eth.gasPrice * 1.40 
    #fromAddress = '0xd621604f3b808a42a65D4eB73E192c1E04b8504c'
    selectedAuction = web3.eth.contract(address=auctionBox.address, abi=auctionBox.abi)
    nonce = web3.eth.getTransactionCount(fromAddress)+1
    print(nonce)
    transaction = selectedAuction.functions.createAuction(
    title,
    startPrice, 
    description, 
    count, 
    commission ).buildTransaction({
    'gas': 7000000,
    'gasPrice': web3.toWei('1', 'gwei'),
    'from': fromAddress,
    'nonce': nonce
    }) 
    private_key = users[fromAddress]
    signed_txn = web3.eth.account.signTransaction(transaction, private_key=private_key)
    web3.eth.sendRawTransaction(signed_txn.rawTransaction)

    return "ok"
    

@app.route('/handleSubmitSale', methods=["POST"]) 
def handleSubmitSale():
    data = request.get_json(force=True)
    nameOfGoods = data['nameOfGood'] #[]
    amounts = data['amount'] #[]
    address_auctions = data['address_auction'] #[]
    fromAddress = data['fromAddress'] 
    
    #fromAddress = '0xd621604f3b808a42a65D4eB73E192c1E04b8504c'
    selectedAuction = web3.eth.contract(address=auctionBox.address, abi=auctionBox.abi)
    nonce = web3.eth.getTransactionCount(fromAddress)

    transaction = selectedAuction.functions.saleOfGoodsBox(
    nameOfGoods,
    amounts,
    address_auctions,
    ).buildTransaction({
    'gas': 7000000,
    'gasPrice': web3.toWei('1', 'gwei'),
    'from': fromAddress,
    'nonce': nonce
    }) 
    private_key = users[fromAddress]
    signed_txn = web3.eth.account.signTransaction(transaction, private_key=private_key)
    web3.eth.sendRawTransaction(signed_txn.rawTransaction)
    auctionBox_contract.functions.saleOfGoods(nameOfGood, amount, address_auction)





'''
def handleSubmit():
    #data = request.get_json(force=True)
    #address_auctions = data['address_auction'] #[]
    #amounts = data['amount'] #[]
    fromAddress ='0xd621604f3b808a42a65D4eB73E192c1E04b8504c' 

    address_auctions=['0x527d7462Ec9c5f3e94F1A87Cd3D00816827Da204']
    amounts=[1]
    
    #fromAddress = '0xd621604f3b808a42a65D4eB73E192c1E04b8504c'
    selectedAuction = web3.eth.contract(address=auctionBox.address, abi=auctionBox.abi)
    nonce = web3.eth.getTransactionCount(fromAddress)

    transaction = selectedAuction.functions.placeBidBox(
    address_auctions,
    amounts,
    fromAddress
    ).buildTransaction({
    'gas': 7000000,
    'gasPrice': web3.toWei('1', 'gwei'),
    'from': fromAddress,
    'nonce': nonce
    }) 
    private_key = users[fromAddress]
    signed_txn = web3.eth.account.signTransaction(transaction, private_key=private_key)
    web3.eth.sendRawTransaction(signed_txn.rawTransaction)
    #print(web3.eth.sendRawTransaction(signed_txn.rawTransaction))
    #return true

    '''

#handleSubmit()

from web3 import Web3
web3 = Web3(Web3.HTTPProvider("https://ropsten.infura.io/v3/d69e87bc2ea3413d86e0df7b6324a96f"))
my_account = web3.eth.account.create('Idet2050! blockchain') # 'Idet2050! blockchain' это как бы пароль
print(my_account._address)
#'0xB2644A65B6AECa470Cd584e5B7F4D0a541722753'
print(my_account._private_key)
#HexBytes('0x54713dbcf4b0efc35999db010e91097e3abc19d9e316d4b2b7eb1f7bf88b0eb6')




from web3.auto import w3
with open("~/.ethereum/rinkeby/keystore/UTC--2018-06-10T05-43-22.134895238Z--9e63c0d223d9232a4f3076947ad7cff353cc1a28") 
    as keyfile:
    encrypted_key = keyfile.read()
    private_key = w3.eth.account.decrypt(encrypted_key,'password')



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8839, threaded=True)