require 'json'
require 'openssl'

class BlockChain
    attr_accessor :chain, :current_transactions

    # class methods
    class << self
        def hash(block)
            block_string = JSON.generate(block)
            return OpenSSL::Digest.hexdigest('sha256', block_string)
        end
        def valid_proof(last_proof, proof)
            hash = OpenSSL::Digest.hexdigest('sha256', "#{last_proof}#{proof}")
            return hash.slice(-4, 4) == "0000"
        end
    end

    def initialize
        @chain = []
        @current_transactions = []

        new_block(1, 100)
    end

    def new_block(previous_hash = "None", proof = 0)
        block = {
            index: @chain.length + 1,
            timestamp: Time.now.to_f,
            transactions: @current_transactions,
            proof: proof,
            previous_hash: previous_hash || self.class.hash(@chain[-1])
        }
        @current_transactions = []
        @chain << block

        return block
    end

    def new_transaction(sender, recipient, amount)
        @current_transactions << {
            sender: sender,
            recipient: recipient,
            amount: amount
        }
        return last_block[:index] + 1
    end

    def last_block
        return @chain[-1]
    end

    def proof_of_work(last_proof)
        proof = 0
        while !self.class.valid_proof(last_proof, proof)
            proof = proof + 1
        end
        return proof
    end


end
