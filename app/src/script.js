import 'core-js/stable'
import 'regenerator-runtime/runtime'
import AragonApi from '@aragon/api'

const api = new AragonApi()
let account

api.store(
  async (state, event) => {
    let newState

    switch (event.event) {
      case 'ACCOUNTS_TRIGGER':
        account = event.returnValues.account
        newState = state
        break
      case 'Subscribe':
        console.log(event)
        const subscription = {
          subscriber: event.returnValues.subscriber,
          expiration: new Date(parseInt(event.returnValues.expiration)*1000),
          purchaser: event.returnValues.purchaser
        }
        newState = { ...state, subscriptions: [subscription].concat(state.subscriptions) }
        break
      default:
        newState = state
    }

    return newState
  },
  {
    init: async function(){
      return {
        subscriptions: [],
        price: await api.call("price").toPromise(),
        duration: await api.call("duration").toPromise()
      }
    }
  }
)
