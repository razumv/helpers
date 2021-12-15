1. Task 1
`curl -s https://raw.githubusercontent.com/razumv/helpers/main/subquery/ex3/ex3_t1.sh | bash`

check in browser:
`query {
  transfers(first: 5, orderBy:AMOUNT_DESC) {
    nodes {
      id
      amount
      blockNumber
      to {
        id
      }
    }
  }
}`

after check:
`cd $HOME/SubQ/tutorials-account-transfers/ && docker-compose down`
2. Task 2
`curl -s https://raw.githubusercontent.com/razumv/helpers/main/subquery/ex3/ex3_t2.sh | bash`

check in browser:
`query {
  councillors(first: 5, orderBy: NUMBER_OF_VOTES_DESC) {
    nodes {
      id
      numberOfVotes
      voteHistory(first: 3) {
        totalCount
        nodes {
          approvedVote
        }
      }
    }
  }
}`

after check:
`cd $HOME/SubQ/tutorials-council-proposals/ && docker-compose down`
3. Task 3
`curl -s https://raw.githubusercontent.com/razumv/helpers/main/subquery/ex3/ex3_t3.sh | bash`

check in browser:
`query{
  accounts(first:5){
    nodes{
      id
      myToAddress{
        nodes{
          id
          amount
        }
      }
    }
  }
}`

after check:
`cd $HOME/SubQ/tutorials-account-transfer-reverse-lookups/ && docker-compose down`
