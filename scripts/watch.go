package main

import (
    "fmt"
    "log"
    "context"
    "math/big"
    "strings"

    "github.com/ethereum/go-ethereum"
    "github.com/ethereum/go-ethereum/accounts/abi"
    "github.com/ethereum/go-ethereum/common"
    "github.com/ethereum/go-ethereum/crypto"
    "github.com/ethereum/go-ethereum/ethclient"
    "github.com/ethereum/go-ethereum/core/types"

    subscribe "../go"
)

func main() {
    client, err := ethclient.Dial("wss://rinkeby.infura.io/ws")
    if err != nil {
        log.Fatal(err)
    }

    const SubscribeAddress string = "0x41d32795f6ed4026fdbd9261407d618dfcb350a7"

    fmt.Println("we have a connection")

    subscribeAddress := common.HexToAddress(SubscribeAddress)
    // Get contract instances to call methods on them
    subscribeInstance, _ := subscribe.NewSubscribe(subscribeAddress, client)
    _ = subscribeInstance

    subscribeAbi, _ := abi.JSON(strings.NewReader(string(subscribe.SubscribeABI)))

    transferEventSigHash := crypto.Keccak256Hash([]byte("Subscribe(address,address,uint64)"))

    query := ethereum.FilterQuery{
        FromBlock: big.NewInt(5356339),
        Addresses: []common.Address{subscribeAddress},
    }

    // We can process any events since `FromBlock`
    past, _ := client.FilterLogs(context.Background(), query)

    for _, vLog := range past {

      // The transaction hash can work as a unique transaction identifier (for example, checking whether a transaction been processed/synced)
      fmt.Println("\nTxHash:", vLog.TxHash.Hex())

      switch vLog.Topics[0] {
    	case transferEventSigHash:
          switch vLog.Address {
          case subscribeAddress:
              fmt.Println("Subscribe")
          default:
              fmt.Println("unrecognised Subscribe event")
          }

          var event subscribe.SubscribeSubscribe
          subscribeAbi.Unpack(&event, "Subscribe", vLog.Data)
          var subscriberAddress common.Address = common.HexToAddress(vLog.Topics[1].Hex())
          var purchaserAddress common.Address = common.HexToAddress(event.Purchaser.Hex())
          fmt.Println("\tSubscriber:", subscriberAddress.Hex())
          fmt.Println("\tPurchaser:", purchaserAddress.Hex())
          fmt.Println("\tExpiration:", event.Expiration)

          switch vLog.Address {
          case subscribeAddress:
              subscriberExpiration, _ := subscribeInstance.Expirations(nil, subscriberAddress)
              fmt.Println("\tSubscriber new expiration:", subscriberExpiration)
          }

    	default:
		      fmt.Println("not a monitored event")
    	}
    }

    // As well as process past events we can create an event subscription and monitor for ongoing events
    logs := make(chan types.Log)

    sub, err := client.SubscribeFilterLogs(context.Background(), query, logs)
    if err != nil {
        log.Fatal(err)
    }

    for {
        select {
        case err := <-sub.Err():
            log.Fatal(err)
        case vLog := <-logs:
          switch vLog.Topics[0] {
          case transferEventSigHash:
              switch vLog.Address {
              case subscribeAddress:
                  fmt.Println("Subscribe")
              default:
                  fmt.Println("unrecognised Subscribe event")
              }
          default:
              fmt.Println("not a monitored event")
          }
        }
    }
}
