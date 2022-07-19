import {
  Transaction,
  useStarknetTransactionManager,
} from '@starknet-react/core'

function TransactionItem({ transaction }: { transaction: Transaction }) {
  return (
    <span>
      <a
        href={`https://goerli.voyager.online/tx/${transaction.transactionHash}`}
      >
        {transaction.metadata.method}: {transaction.metadata.message} -{' '}
        {transaction.status}
      </a>
    </span>
  )
}

export function TransactionList() {
  const { transactions } = useStarknetTransactionManager()

  if (transactions.length === 0) return null

  return (
    <div>
      <h3>Transactions: </h3>
      <ul>
        {transactions.map((transaction, index) => (
          <li key={index}>
            <TransactionItem transaction={transaction} />
          </li>
        ))}
      </ul>
    </div>
  )
}

export default TransactionList
