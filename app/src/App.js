import React, { useState, useEffect } from 'react'
import { useAragonApi } from '@aragon/api-react'
import {
  AppBar, AppView, Button, Card, CardLayout, Checkbox, Field, GU, Header, IconSettings,
  Info, Main, Modal, SidePanel, Text, TextInput, theme
} from '@aragon/ui'
import BigNumber from 'bignumber.js'

function App() {
  const { api, network, appState, connectedAccount } = useAragonApi()
  const { price, duration, subscriptions = [], syncing } = appState

  const [ admin, setAdmin ] = useState(false)
  const [ units, setUnits ] = useState(2)
  const [ newPrice, setNewPrice ] = useState(0)
  const [ newDuration, setNewDuration ] = useState(0)
  const [ recipient, setRecipient ] = useState(0)
  const [ accountSubscription, setAccountSubscription ] = useState()


  useEffect(()=>{
    connectedAccount && !recipient && setRecipient(connectedAccount)
    price && !newPrice && setNewPrice(price)
    duration && !newDuration && setNewDuration(duration)
  }, [connectedAccount, price, duration])

  const [ subscription, setSubscription ] = useState()
  useEffect(()=>{
    // console.log(subscriptions)
    // let mysubs = subscriptions.filter(({subscriber})=>subscriber===connectedAccount)
    // console.log(mysubs)
    // let end = mysubs.reduce((p,c)=>{
    //   const start = c.start > p ? c.start : p
    //   return start + c.duration
    // }, 0)
    // console.log(end)
    // setEnding(end);
    let sub = subscriptions.find(({subscriber})=>subscriber===connectedAccount)
    setSubscription(sub)
  }, [subscriptions])

  return (
    <Main>
      <Header primary="Special Membership" secondary={<Button label="Admin" onClick={()=>{setAdmin(true)}} />} />
      {subscription && isFuture(subscription.expiration) ? <Text>{`Special Membership active and expiring ${subscription.expiration}`}</Text> : <Text>No active Special Membership subscription</Text>}
      <Field label="Number of subscription units:">
        <input type="number" value={units} onChange={(e)=>setUnits(e.target.value)} />
      </Field>
      <Field label="Subscriber:">
        <input value={recipient} onChange={(e)=>setRecipient(e.target.value)} /> {recipient === connectedAccount && <span>(yourself)</span>}
      </Field>
      <Text>{`Subscribe to Special Membership for ${units*duration/(24*60*60)} days by burning ${BigNumber(units*price).div("1e+18")} tokens`}</Text>
      <Field>
        <Button mode="positive" label="Subscribe" onClick={()=>api.subscribe(recipient, units).toPromise()} />
      </Field>
      <SidePanel title="Menu" opened={admin} onClose={()=>setAdmin(false)}>
        <Field label="Set subscription price:">
          <input type="number" value={newPrice} onChange={(e)=>setNewPrice(e.target.value)} />
          <Button mode="strong" label="Set price" onClick={()=>api.setPrice(newPrice).toPromise()} />
        </Field>
        <Field label="Set subscription duration:">
          <input type="number" value={newDuration} onChange={(e)=>setNewDuration(e.target.value)} />
          <Button mode="strong" label="Set duration" onClick={()=>api.setDuration(newDuration).toPromise()} />
        </Field>
      </SidePanel>
    </Main>
  )
}

function getTimeRemaining({start,duration}){
  const now = Math.round(new Date().getTime()/1000)
  const remaining = start + duration - now
  return remaining > 0 ? remaining : 0
}

function isFuture(time){
  return time > new Date()
}

export default App
