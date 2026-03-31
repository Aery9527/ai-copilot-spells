# Mermaid Diagram Examples

Per-type syntax examples for reference. Load this file when producing Mermaid diagrams.

---

## Flowchart (Module Dependencies / Pipeline)

Top-down for hierarchies:

```mermaid
flowchart TD
    Common[game-go-common<br/>基礎工具庫]
    Core[slot-core<br/>遊戲引擎]
    Infra[game-go-infra<br/>基礎設施]
    Common --> Core
    Common --> Infra
    Core --> App[game-slot-gp-app<br/>應用層]
    Infra --> App
```

Left-to-right for pipelines:

```mermaid
flowchart LR
    A[解析請求] --> B[讀取狀態]
    B --> C[執行遊戲邏輯]
    C --> D[更新餘額]
    D --> E[寫入紀錄]
    E --> F[保存狀態]
    F --> G[回應結果]
```

With subgraph grouping:

```mermaid
flowchart TD
    subgraph Common["game-go-common"]
        glog[glog]
        gerror[gerror]
        gitem[gitem]
    end
    subgraph Core["slot-core"]
        engine[engine]
        cf[cf]
    end
    Common --> Core
```

---

## Sequence Diagram (Component Interaction)

```mermaid
sequenceDiagram
    participant Client
    participant GinAdapter
    participant SpinEntry
    participant GameAction
    participant BalanceUpdater

    Client->>GinAdapter: HTTP Request
    activate GinAdapter
    GinAdapter->>SpinEntry: Parse & Spin()
    activate SpinEntry
    SpinEntry->>GameAction: Launch() / Next()
    activate GameAction
    GameAction-->>SpinEntry: SpinResult
    deactivate GameAction
    SpinEntry->>BalanceUpdater: UpdateBalance()
    BalanceUpdater-->>SpinEntry: ok
    SpinEntry-->>GinAdapter: FlowResult
    deactivate SpinEntry
    GinAdapter-->>Client: JSON Response
    deactivate GinAdapter
```

---

## Class Diagram (Interface / Struct Relationships)

```mermaid
classDiagram
    class GameAction {
        <<interface>>
        +Launch(ctx, params) SpinResult
        +Next(ctx, params) SpinResult
    }
    class MahjongAction {
        -config Config
        +Launch(ctx, params) SpinResult
        +Next(ctx, params) SpinResult
    }
    GameAction <|.. MahjongAction : implements

    class Symbol {
        <<interface>>
        +ID() int
        +Display() string
        +IsWild() bool
    }
    class BaseSymbol {
        -id int
        -display string
    }
    Symbol <|.. BaseSymbol : implements
```

---

## State Diagram (Game State / Lifecycle)

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Spinning : Launch Spin
    Spinning --> Evaluating : 轉輪停止
    Evaluating --> FreeGame : 觸發免費遊戲
    Evaluating --> Idle : 無特殊觸發
    FreeGame --> Spinning : Next Spin
    FreeGame --> Idle : 免費遊戲結束
```

---

## ER Diagram (Data Model)

```mermaid
erDiagram
    USER ||--o{ ROUND : plays
    ROUND ||--|{ SPIN_RECORD : contains
    ROUND {
        string roundID PK
        string userID FK
        int gameID
        money totalBet
        money totalWin
    }
    SPIN_RECORD {
        string recordID PK
        string roundID FK
        int spinIndex
        json gridResult
        money winAmount
    }
```

---

## Combining Diagrams

When documenting a complex feature, use multiple diagram types in one document:

1. **flowchart** for the high-level architecture or module dependency
2. **sequenceDiagram** for the runtime interaction between components
3. **stateDiagram-v2** for any state machine or lifecycle
4. **classDiagram** for interface/struct type relationships if needed

Choose the minimum set of diagrams that fully conveys the feature. Avoid redundancy between diagrams.
