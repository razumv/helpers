#!/bin/bash

sudo tee <<EOF >/dev/null $HOME/staking-rewards/schema.graphql
type StakingReward @entity{
id: ID! #blockHeight-eventIdx
account: String!
balance: BigInt!
date: Date!
blockHeight: Int!
}
EOF

sudo tee <<EOF >/dev/null $HOME/staking-rewards/project.yaml
specVersion: 0.2.0
name: staking-rewards
version: 1.0.0
description: doubletop
repository: https://github.com/subquery/subql-starter
schema:
  file: ./schema.graphql
network:
  endpoint: wss://polkadot.api.onfinality.io/public-ws
  genesisHash: '0x91b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3'
dataSources:
  - kind: substrate/Runtime
    startBlock: 7000000
    mapping:
      file: ./dist/index.js
      handlers:
        - handler: handleStakingRewarded
          kind: substrate/EventHandler
          filter:
            module: staking
            method: Rewarded
EOF

sudo tee <<EOF >/dev/null $HOME/staking-rewards/src/mappings/mappingHandlers.ts
import {SubstrateEvent} from "@subql/types";
import {StakingReward} from "../types";
import {Balance} from "@polkadot/types/interfaces";

export async function handleStakingRewarded(event: SubstrateEvent):
Promise<void> {
    const {event: {data: [account, newReward]}} = event;
    const entity = new StakingReward(`${event.block.block.header.number}-${event.idx.toString()}`);
    entity.account = account.toString();
    entity.balance = (newReward as Balance).toBigInt();
    entity.date = event.block.timestamp;
    entity.blockHeight = event.block.block.header.number.toNumber();
    await entity.save();
}
EOF

sudo tee <<EOF >/dev/null $HOME/staking-rewards/docker-compose.yml
version: '3'

services:
  postgres:
    image: postgres:12-alpine
    ports:
      - 5432:5432
    volumes:
      - .data/postgres:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: postgres

  subquery-node:
    image: onfinality/subql-node:v0.25.3
    depends_on:
      - "postgres"
    restart: always
    environment:
      DB_USER: postgres
      DB_PASS: postgres
      DB_DATABASE: postgres
      DB_HOST: postgres
      DB_PORT: 5432
    volumes:
      - ./:/app
    command:
      - -f=/app
      - --db-schema=app

  graphql-engine:
    image: onfinality/subql-query:v0.8.0
    ports:
      - 3000:3000
    depends_on:
      - "postgres"
      - "subquery-node"
    restart: always
    environment:
      DB_USER: postgres
      DB_PASS: postgres
      DB_DATABASE: postgres
      DB_HOST: postgres
      DB_PORT: 5432
    command:
      - --name=app
      - --playground
      - --indexer=http://subquery-node:3000
EOF
