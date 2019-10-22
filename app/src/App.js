import React, { useState, useEffect } from 'react'
import { useAragonApi } from '@aragon/api-react'
import {
  AppBar, AppView, Button, Card, CardLayout, Checkbox, Field, GU, Header, IconSettings,
  Info, Main, Modal, SidePanel, Text, TextInput, theme
} from '@aragon/ui'

function App() {
  const { api, network, appState, connectedAccount } = useAragonApi()
  const { subscriptions = [], syncing } = appState

  return (
    <Main>
      <Header primary="Subscription" secondary={<Button mode="strong" onClick={()=>{}}>Admin</Button>} />
      <ul>
        {subscriptions.map(s=>JSON.stringify(s))}
      </ul>
    </Main>
  )
}

export default App
