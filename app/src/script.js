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
        const subscription = {subscriber: event.returnValues.subscriber, units: event.returnValues.units}
        newState = { ...state, subscriptions: [subscription].concat(state.subscriptions) }
        break
      default:
        newState = state
    }

    return newState
  },
  {
    init: async function(){
      return { subscriptions: [] }
    }
  }
)
