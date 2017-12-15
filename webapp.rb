require 'sinatra'
require 'sinatra/param'
require 'securerandom'
require './block_chain'

blockchain = BlockChain.new
node_identifier = SecureRandom.uuid.delete('-')

get '/mine' do
    last_block = blockchain.last_block
    last_proof = last_block[:proof]
    proof = blockchain.proof_of_work(last_proof)

    blockchain.new_transaction('0', node_identifier, 1)
    previous_hash = BlockChain.hash(last_block)
    block = blockchain.new_block(previous_hash, proof)

    return {
        message: "New Block Forged",
        index: block[:index],
        transactions: block[:transactions],
        proof: block[:proof],
        previous_hash: block[:previous_hash]
    }.to_json
end

post '/transactions/new' do
    param :sender, String, required: true
    param :recipient, String, required: true
    param :amount, Integer, required: true

    index = blockchain.new_transaction(params[:sender], params[:recipient], params[:amount])
    return {
        message: "Transaction will be added to Block  #{index}"
    }.to_json
end

get '/chain' do
    chain = blockchain.chain
    return {
        chain: chain,
        length: chain.length
    }.to_json
end