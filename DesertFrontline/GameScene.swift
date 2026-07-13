import SpriteKit
import UIKit

private enum Faction: String, Hashable {
    case player
    case enemy
    case neutral

    var displayName: String {
        switch self {
        case .player: "Blue Force"
        case .enemy: "Red Force"
        case .neutral: "Neutral"
        }
    }

    var color: UIColor {
        switch self {
        case .player: UIColor(red: 0.18, green: 0.46, blue: 0.95, alpha: 1.0)
        case .enemy: UIColor(red: 0.86, green: 0.19, blue: 0.15, alpha: 1.0)
        case .neutral: UIColor(white: 0.72, alpha: 1.0)
        }
    }
}

private enum Terrain {
    case sand
    case road
    case water
    case oil
    case ridge
}

private enum Domain {
    case land
    case air
    case naval
    case structure
}

private enum EntityKind: CaseIterable, Hashable {
    case hq
    case barracks
    case airfield
    case shipyard
    case oilDerrick
    case radarOutpost
    case sonarBuoy
    case guardTower
    case samSite
    case coastalBattery
    case aaTruck
    case humvee
    case tank
    case artillery
    case mechanic
    case helicopter
    case fighter
    case battleship
    case submarine
    case carrier

    var displayName: String {
        switch self {
        case .hq: "Command HQ"
        case .barracks: "War Factory"
        case .airfield: "Airfield"
        case .shipyard: "Shipyard"
        case .oilDerrick: "Oil Derrick"
        case .radarOutpost: "Radar Outpost"
        case .sonarBuoy: "Sonar Buoy"
        case .guardTower: "Guard Tower"
        case .samSite: "SAM Site"
        case .coastalBattery: "Coastal Battery"
        case .aaTruck: "AA Truck"
        case .humvee: "Humvee"
        case .tank: "Tank"
        case .artillery: "Artillery"
        case .mechanic: "Mechanic"
        case .helicopter: "Helicopter"
        case .fighter: "Fighter"
        case .battleship: "Battleship"
        case .submarine: "Submarine"
        case .carrier: "Carrier"
        }
    }

    var shortCode: String {
        switch self {
        case .hq: "HQ"
        case .barracks: "WF"
        case .airfield: "AF"
        case .shipyard: "SY"
        case .oilDerrick: "OIL"
        case .radarOutpost: "RAD"
        case .sonarBuoy: "SON"
        case .guardTower: "GT"
        case .samSite: "SAM"
        case .coastalBattery: "CB"
        case .aaTruck: "AA"
        case .humvee: "HMV"
        case .tank: "TNK"
        case .artillery: "ART"
        case .mechanic: "MECH"
        case .helicopter: "HEL"
        case .fighter: "JET"
        case .battleship: "BB"
        case .submarine: "SUB"
        case .carrier: "CV"
        }
    }

    var domain: Domain {
        switch self {
        case .hq, .barracks, .airfield, .shipyard, .oilDerrick, .radarOutpost, .sonarBuoy, .guardTower, .samSite, .coastalBattery:
            .structure
        case .aaTruck, .humvee, .tank, .artillery, .mechanic:
            .land
        case .helicopter, .fighter:
            .air
        case .battleship, .submarine, .carrier:
            .naval
        }
    }

    var isStructure: Bool {
        domain == .structure
    }

    var isFactory: Bool {
        switch self {
        case .hq, .barracks, .airfield, .shipyard, .carrier: true
        default: false
        }
    }

    var supportsRallyPoint: Bool {
        switch self {
        case .barracks, .airfield, .shipyard, .carrier: true
        default: false
        }
    }

    var hasSonar: Bool {
        switch self {
        case .battleship, .submarine, .carrier, .helicopter, .sonarBuoy:
            true
        default:
            false
        }
    }

    var cost: Int {
        switch self {
        case .hq: 3600
        case .barracks: 1800
        case .airfield: 2200
        case .shipyard: 2400
        case .oilDerrick: 900
        case .radarOutpost: 1300
        case .sonarBuoy: 850
        case .guardTower: 1450
        case .samSite: 1650
        case .coastalBattery: 1700
        case .aaTruck: 720
        case .humvee: 420
        case .tank: 650
        case .artillery: 900
        case .mechanic: 500
        case .helicopter: 1200
        case .fighter: 1500
        case .battleship: 1800
        case .submarine: 1400
        case .carrier: 2800
        }
    }

    var buildTime: TimeInterval {
        switch self {
        case .hq: 18.0
        case .barracks: 12.0
        case .airfield: 14.0
        case .shipyard: 14.0
        case .oilDerrick: 8.0
        case .radarOutpost: 10.0
        case .sonarBuoy: 7.0
        case .guardTower: 11.0
        case .samSite: 12.0
        case .coastalBattery: 12.0
        case .aaTruck: 5.5
        case .humvee: 3.5
        case .tank: 5.0
        case .artillery: 7.0
        case .mechanic: 4.0
        case .helicopter: 8.0
        case .fighter: 9.0
        case .battleship: 11.0
        case .submarine: 10.0
        case .carrier: 16.0
        }
    }

    var maxHP: CGFloat {
        switch self {
        case .hq: 1800
        case .barracks: 1000
        case .airfield: 900
        case .shipyard: 1050
        case .oilDerrick: 650
        case .radarOutpost: 720
        case .sonarBuoy: 360
        case .guardTower: 820
        case .samSite: 760
        case .coastalBattery: 780
        case .aaTruck: 170
        case .humvee: 160
        case .tank: 260
        case .artillery: 190
        case .mechanic: 140
        case .helicopter: 230
        case .fighter: 210
        case .battleship: 780
        case .submarine: 420
        case .carrier: 980
        }
    }

    var speed: CGFloat {
        switch self {
        case .aaTruck: 82
        case .humvee: 118
        case .tank: 70
        case .artillery: 48
        case .mechanic: 78
        case .helicopter: 122
        case .fighter: 170
        case .battleship: 42
        case .submarine: 55
        case .carrier: 34
        default: 0
        }
    }

    var attackRange: CGFloat {
        switch self {
        case .hq: 190
        case .guardTower: 205
        case .samSite: 260
        case .coastalBattery: 285
        case .aaTruck: 220
        case .humvee: 125
        case .tank: 145
        case .artillery: 250
        case .helicopter: 170
        case .fighter: 210
        case .battleship: 310
        case .submarine: 185
        case .carrier: 330
        default: 0
        }
    }

    var damage: CGFloat {
        switch self {
        case .hq: 24
        case .guardTower: 30
        case .samSite: 48
        case .coastalBattery: 62
        case .aaTruck: 24
        case .humvee: 18
        case .tank: 34
        case .artillery: 58
        case .helicopter: 28
        case .fighter: 42
        case .battleship: 76
        case .submarine: 72
        case .carrier: 64
        default: 0
        }
    }

    var attackCooldown: TimeInterval {
        switch self {
        case .hq: 1.6
        case .guardTower: 1.25
        case .samSite: 1.55
        case .coastalBattery: 2.15
        case .aaTruck: 0.82
        case .humvee: 0.72
        case .tank: 1.15
        case .artillery: 2.1
        case .helicopter: 0.95
        case .fighter: 1.15
        case .battleship: 2.35
        case .submarine: 2.2
        case .carrier: 2.8
        default: 1.0
        }
    }

    var visionTiles: Int {
        switch self {
        case .hq: 7
        case .barracks, .airfield, .shipyard: 5
        case .oilDerrick: 4
        case .radarOutpost: 9
        case .sonarBuoy: 4
        case .guardTower: 6
        case .samSite: 7
        case .coastalBattery: 6
        case .aaTruck: 7
        case .humvee: 8
        case .artillery, .battleship, .carrier: 7
        case .fighter: 8
        case .helicopter: 7
        case .submarine: 5
        default: 5
        }
    }

    var footprint: CGFloat {
        switch self {
        case .hq: 58
        case .barracks, .airfield, .shipyard: 50
        case .oilDerrick: 42
        case .radarOutpost, .guardTower: 46
        case .sonarBuoy: 44
        case .samSite, .coastalBattery: 48
        case .aaTruck: 30
        case .humvee: 28
        case .carrier: 60
        case .battleship: 50
        default: 32
        }
    }

    var requiredFactory: EntityKind? {
        switch self {
        case .aaTruck, .humvee, .tank, .artillery, .mechanic:
            .barracks
        case .helicopter, .fighter:
            .airfield
        case .battleship, .submarine, .carrier:
            .shipyard
        default:
            nil
        }
    }

    func canProduce(_ product: EntityKind) -> Bool {
        switch self {
        case .barracks:
            return product == .aaTruck || product == .humvee || product == .tank || product == .artillery || product == .mechanic
        case .airfield, .carrier:
            return product == .helicopter || product == .fighter
        case .shipyard:
            return product == .battleship || product == .submarine || product == .carrier
        default:
            return false
        }
    }

    func canAttack(_ target: EntityKind) -> Bool {
        if damage <= 0 {
            return false
        }
        if target == .submarine {
            return self == .submarine || self == .battleship || self == .helicopter || self == .fighter || self == .carrier
        }
        switch self {
        case .hq:
            return target.domain == .land || target.domain == .air
        case .guardTower:
            return target.domain == .land || target.domain == .air || target.isStructure
        case .samSite:
            return target.domain == .air
        case .coastalBattery:
            return target.domain == .naval
        case .aaTruck:
            return target.domain == .air
        case .humvee:
            return target.domain == .land || target.domain == .air || target.isStructure
        case .tank:
            return target.domain == .land || target.isStructure
        case .artillery:
            return target.domain == .land || target.domain == .naval || target.isStructure
        case .helicopter:
            return target.domain == .land || target.domain == .naval || target.isStructure
        case .fighter:
            return target.domain == .air || target.domain == .naval || target.isStructure
        case .battleship:
            return target.domain == .land || target.domain == .naval || target.isStructure
        case .submarine:
            return target.domain == .naval
        case .carrier:
            return target.domain == .air || target.domain == .land || target.domain == .naval || target.isStructure
        default:
            return false
        }
    }
}

private enum VeterancyRank: Int, CaseIterable {
    case recruit
    case hardened
    case veteran
    case elite

    var displayName: String {
        switch self {
        case .recruit: "Recruit"
        case .hardened: "Hardened"
        case .veteran: "Veteran"
        case .elite: "Elite"
        }
    }

    var shortCode: String {
        switch self {
        case .recruit: "REC"
        case .hardened: "HDN"
        case .veteran: "VET"
        case .elite: "ELT"
        }
    }

    var minimumXP: CGFloat {
        switch self {
        case .recruit: 0
        case .hardened: 80
        case .veteran: 200
        case .elite: 420
        }
    }

    var nextThreshold: CGFloat? {
        switch self {
        case .recruit: 80
        case .hardened: 200
        case .veteran: 420
        case .elite: nil
        }
    }

    var damageMultiplier: CGFloat {
        switch self {
        case .recruit: 1.00
        case .hardened: 1.10
        case .veteran: 1.18
        case .elite: 1.28
        }
    }

    var cooldownMultiplier: TimeInterval {
        switch self {
        case .recruit: 1.00
        case .hardened: 0.96
        case .veteran: 0.92
        case .elite: 0.86
        }
    }

    var visionBonus: Int {
        switch self {
        case .recruit, .hardened: 0
        case .veteran, .elite: 1
        }
    }

    var badgeColor: UIColor {
        switch self {
        case .recruit:
            UIColor.clear
        case .hardened:
            UIColor(red: 0.72, green: 0.44, blue: 0.18, alpha: 1.0)
        case .veteran:
            UIColor(red: 0.78, green: 0.82, blue: 0.86, alpha: 1.0)
        case .elite:
            UIColor(red: 1.0, green: 0.77, blue: 0.22, alpha: 1.0)
        }
    }

    static func rank(for xp: CGFloat) -> VeterancyRank {
        VeterancyRank.allCases.last { xp >= $0.minimumXP } ?? .recruit
    }
}

private enum HudAction: String, CaseIterable {
    case selectArmy
    case controlGroup1
    case controlGroup2
    case holdPosition
    case attackMove
    case buildHumvee
    case buildAATruck
    case buildTank
    case buildArtillery
    case buildMechanic
    case buildHelicopter
    case buildFighter
    case buildBattleship
    case buildSubmarine
    case buildCarrier
    case setRally
    case buildBase
    case reconSweep
    case fieldRepair
    case airStrike
    case navalBarrage
    case cycleAI
    case focusHQ
    case newSkirmish

    var title: String {
        switch self {
        case .selectArmy: "ARMY"
        case .controlGroup1: "G1"
        case .controlGroup2: "G2"
        case .holdPosition: "HOLD"
        case .attackMove: "AMOV"
        case .buildHumvee: "HMV"
        case .buildAATruck: "AA"
        case .buildTank: "TANK"
        case .buildArtillery: "ART"
        case .buildMechanic: "MECH"
        case .buildHelicopter: "HELI"
        case .buildFighter: "JET"
        case .buildBattleship: "SHIP"
        case .buildSubmarine: "SUB"
        case .buildCarrier: "CV"
        case .setRally: "RLY"
        case .buildBase: "BASE"
        case .reconSweep: "SCAN"
        case .fieldRepair: "REPR"
        case .airStrike: "AIRS"
        case .navalBarrage: "BARR"
        case .cycleAI: "AI"
        case .focusHQ: "HQ"
        case .newSkirmish: "SKRM"
        }
    }

    var buildKind: EntityKind? {
        switch self {
        case .buildHumvee: .humvee
        case .buildAATruck: .aaTruck
        case .buildTank: .tank
        case .buildArtillery: .artillery
        case .buildMechanic: .mechanic
        case .buildHelicopter: .helicopter
        case .buildFighter: .fighter
        case .buildBattleship: .battleship
        case .buildSubmarine: .submarine
        case .buildCarrier: .carrier
        default: nil
        }
    }

    var supportPower: SupportPower? {
        switch self {
        case .reconSweep: .reconSweep
        case .fieldRepair: .fieldRepair
        case .airStrike: .airStrike
        case .navalBarrage: .navalBarrage
        default: nil
        }
    }
}

private enum HudPage: String, CaseIterable {
    case tactical
    case build
    case air
    case naval
    case support

    var title: String {
        switch self {
        case .tactical: "TACT"
        case .build: "BUILD"
        case .air: "AIR"
        case .naval: "SEA"
        case .support: "SUP"
        }
    }

    var subtitle: String {
        switch self {
        case .tactical: "orders"
        case .build: "base"
        case .air: "wing"
        case .naval: "fleet"
        case .support: "ops"
        }
    }

    var actions: [HudAction] {
        switch self {
        case .tactical:
            [.selectArmy, .controlGroup1, .controlGroup2, .holdPosition, .attackMove, .setRally, .focusHQ]
        case .build:
            [.buildHumvee, .buildAATruck, .buildTank, .buildArtillery, .buildMechanic, .buildBase]
        case .air:
            [.buildHelicopter, .buildFighter]
        case .naval:
            [.buildBattleship, .buildSubmarine, .buildCarrier]
        case .support:
            [.reconSweep, .fieldRepair, .airStrike, .navalBarrage, .cycleAI, .newSkirmish]
        }
    }
}

private enum SupportPower: CaseIterable, Hashable {
    case reconSweep
    case fieldRepair
    case airStrike
    case navalBarrage

    var displayName: String {
        switch self {
        case .reconSweep: "Recon Sweep"
        case .fieldRepair: "Field Repair"
        case .airStrike: "Air Strike"
        case .navalBarrage: "Naval Barrage"
        }
    }

    var cost: Int {
        switch self {
        case .reconSweep: 450
        case .fieldRepair: 850
        case .airStrike: 1100
        case .navalBarrage: 1350
        }
    }

    var cooldown: TimeInterval {
        switch self {
        case .reconSweep: 18
        case .fieldRepair: 26
        case .airStrike: 28
        case .navalBarrage: 34
        }
    }

    var radius: CGFloat {
        switch self {
        case .reconSweep: 265
        case .fieldRepair: 150
        case .airStrike: 132
        case .navalBarrage: 156
        }
    }

    var damage: CGFloat {
        switch self {
        case .reconSweep: 0
        case .fieldRepair: 0
        case .airStrike: 210
        case .navalBarrage: 260
        }
    }

    var repairAmount: CGFloat {
        switch self {
        case .fieldRepair: 190
        default: 0
        }
    }
}

private enum MissionStage: Int, CaseIterable, Hashable {
    case secureOil
    case captureFrontline
    case secureCoast
    case combinedArms
    case breakRedProduction
    case destroyHQ

    var title: String {
        switch self {
        case .secureOil: "Secure Oil"
        case .captureFrontline: "Capture Frontline"
        case .secureCoast: "Secure Coast"
        case .combinedArms: "Deploy Combined Arms"
        case .breakRedProduction: "Break Red Production"
        case .destroyHQ: "Destroy Red HQ"
        }
    }
}

private struct SupportPowerKey: Hashable {
    let faction: Faction
    let power: SupportPower
}

private enum AIDifficulty: String {
    case easy
    case normal
    case hard

    var displayName: String {
        switch self {
        case .easy: "Easy"
        case .normal: "Normal"
        case .hard: "Hard"
        }
    }

    var commandInterval: TimeInterval {
        switch self {
        case .easy: 5.2
        case .normal: 3.4
        case .hard: 2.3
        }
    }

    var incomeBonus: Int {
        switch self {
        case .easy: 0
        case .normal: 80
        case .hard: 180
        }
    }

    var buildOrdersPerCycle: Int {
        switch self {
        case .easy: 1
        case .normal: 1
        case .hard: 2
        }
    }

    var attackGroupSize: Int {
        switch self {
        case .easy: 5
        case .normal: 4
        case .hard: 3
        }
    }

    var supportSpendReserve: Int {
        switch self {
        case .easy: 2600
        case .normal: 1900
        case .hard: 1250
        }
    }

    var supportStrikeThreshold: CGFloat {
        switch self {
        case .easy: 1200
        case .normal: 900
        case .hard: 680
        }
    }

    var supportRepairThreshold: CGFloat {
        switch self {
        case .easy: 950
        case .normal: 680
        case .hard: 520
        }
    }

    var usesReconSupport: Bool {
        self != .easy
    }

    var next: AIDifficulty {
        switch self {
        case .easy: .normal
        case .normal: .hard
        case .hard: .easy
        }
    }
}

private struct TileCoord: Hashable {
    let row: Int
    let col: Int
}

private struct BuildOrder {
    let kind: EntityKind
    let faction: Faction
    let sourceID: Int
    let duration: TimeInterval
    var remaining: TimeInterval
}

private enum EnemyCaptureReservation: Hashable {
    case oilDerrick(Int)
    case controlPoint(Int)
}

private enum SceneryKind {
    case village
    case oasis
    case farm
    case depot
    case wreck
}

@MainActor
private final class BattlefieldControlPoint {
    let id: Int
    let name: String
    var faction: Faction
    var captureProgress: CGFloat = 0
    var capturingFaction: Faction?
    let node = SKNode()
    let flag: SKShapeNode
    let ring: SKShapeNode
    let label: SKLabelNode
    let progressBack: SKShapeNode
    let progressFill: SKShapeNode

    init(id: Int, name: String, position: CGPoint) {
        self.id = id
        self.name = name
        self.faction = .neutral
        self.flag = SKShapeNode(rectOf: CGSize(width: 24, height: 14), cornerRadius: 1.5)
        self.ring = SKShapeNode(ellipseOf: CGSize(width: 72, height: 34))
        self.label = SKLabelNode(fontNamed: "Menlo-Bold")
        self.progressBack = SKShapeNode(rectOf: CGSize(width: 50, height: 6), cornerRadius: 1.5)
        self.progressFill = SKShapeNode(rectOf: CGSize(width: 50, height: 4), cornerRadius: 1)
        node.position = position
        node.name = "control:\(id)"
    }
}

@MainActor
private final class GameEntity {
    let id: Int
    let kind: EntityKind
    var faction: Faction
    var hp: CGFloat
    var destination: CGPoint?
    var path: [CGPoint] = []
    weak var attackTarget: GameEntity?
    var holdPosition: CGPoint?
    var guardAnchorCarrierID: Int?
    var attackMoveDestination: CGPoint?
    var attackTimer: TimeInterval = 0
    var revealedUntil: TimeInterval = 0
    var veterancyXP: CGFloat = 0
    var killCount = 0
    var captureProgress: CGFloat = 0
    var buildDuration: TimeInterval = 0
    var buildProgressRemaining: TimeInterval = 0
    var rallyPoint: CGPoint?
    let node = SKNode()
    let selectionNode: SKShapeNode
    let sonarCoverageNode = SKShapeNode()
    let escortCoverageNode = SKShapeNode()
    let navalGunRangeNode = SKShapeNode()
    let repairCoverageNode = SKShapeNode()
    let carrierGuardAnchorCoverageNode = SKShapeNode()
    let airDefenseThreatCoverageNode = SKShapeNode()
    let airDefenseThreatMarkerNode = SKNode()
    let healthFill: SKShapeNode
    let teamFlag: SKShapeNode
    let label: SKLabelNode
    let productionNode = SKNode()
    let rallyNode = SKNode()
    let commandIntentNode = SKNode()
    let veterancyNode = SKNode()
    let captureNode = SKNode()
    let constructionNode = SKNode()
    let navalWakeNode = SKNode()
    let airShadowNode = SKNode()

    init(id: Int, kind: EntityKind, faction: Faction, position: CGPoint) {
        self.id = id
        self.kind = kind
        self.faction = faction
        self.hp = kind.maxHP
        self.selectionNode = SKShapeNode(ellipseOf: CGSize(width: kind.footprint * 1.55, height: kind.footprint * 0.82))
        self.healthFill = SKShapeNode(rectOf: CGSize(width: kind.footprint, height: 5), cornerRadius: 1)
        self.teamFlag = SKShapeNode(rectOf: CGSize(width: 15, height: 10))
        self.label = SKLabelNode(fontNamed: "Menlo-Bold")
        node.position = position
        node.name = "entity:\(id)"
        node.userData = ["entityID": id]
    }

    var isAlive: Bool {
        hp > 0
    }

    var isOperational: Bool {
        !kind.isStructure || buildProgressRemaining <= 0
    }

    var veterancyRank: VeterancyRank {
        VeterancyRank.rank(for: veterancyXP)
    }

    var nextVeterancyThreshold: CGFloat? {
        veterancyRank.nextThreshold
    }
}

@MainActor
final class GameScene: SKScene {
    private let rows = 24
    private let cols = 30
    private let tileWidth: CGFloat = 86
    private let tileHeight: CGFloat = 43

    private let worldNode = SKNode()
    private let mapNode = SKNode()
    private let entityLayer = SKNode()
    private let effectsLayer = SKNode()
    private let focusFireMarkerNode = SKNode()
    private let fogLayer = SKNode()
    private let hudNode = SKNode()
    private let cameraRig = SKCameraNode()

    private var terrain: [[Terrain]] = []
    private var fogNodes: [TileCoord: SKShapeNode] = [:]
    private var exploredTiles = Set<TileCoord>()
    private var visibleTiles = Set<TileCoord>()
    private var worldBounds = CGRect.zero

    private var entities: [Int: GameEntity] = [:]
    private var controlPoints: [BattlefieldControlPoint] = []
    private var selectedIDs = Set<Int>()
    private var controlGroups: [Int: Set<Int>] = [1: [], 2: []]
    private var pendingControlGroupRecallTokens: [Int: Int] = [:]
    private var nextControlGroupRecallToken = 0
    private var nextEntityID = 1

    private var playerMoney = 5200
    private var enemyMoney = 5200
    private var buildOrders: [BuildOrder] = []
    private var enemyCaptureReservations: [Int: EnemyCaptureReservation] = [:]
    private var enemyRetreatingUnitIDs = Set<Int>()
    private var aiBuildCursor = 0
    private var aiDifficulty: AIDifficulty = .normal
    private var lastEnemyAssaultWaveSummary: String?
    private var lastEnemyAssaultWaveSummaryTime: TimeInterval = -100
    private let buildableStructures: [EntityKind] = [.barracks, .airfield, .radarOutpost, .sonarBuoy, .guardTower, .samSite, .coastalBattery, .shipyard, .oilDerrick]
    private var structureBuildCursor = 0
    private var pendingConstructionKind: EntityKind?
    private var pendingSupportPower: SupportPower?
    private var supportCooldowns: [SupportPowerKey: TimeInterval] = [:]
    private var supportRevealTiles: [TileCoord: TimeInterval] = [:]
    private var isSettingRallyPoint = false
    private var isSettingAttackMove = false
    private var constructionPreviewNode: SKNode?
    private var skirmishSeed = 0

    private var lastUpdateTime: TimeInterval = 0
    private var incomeAccumulator: TimeInterval = 0
    private var aiAccumulator: TimeInterval = 0
    private var fogAccumulator: TimeInterval = 0
    private var lastPlayerAttackAlertTime: TimeInterval = -100
    private var lastEnemyDefenseResponseTime: TimeInterval = -100
    private var lastEnemyControlPointDefenseResponseTime: TimeInterval = -100
    private var victoryState: String?
    private var completedMissionStages = Set<MissionStage>()

    private let enemyRetreatHealthThreshold: CGFloat = 0.38
    private let enemyRetreatRecoveryThreshold: CGFloat = 0.62
    private let enemyAssaultWaveSummaryDuration: TimeInterval = 12

    private var moneyLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var incomeLabel = SKLabelNode(fontNamed: "Menlo")
    private var selectedLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var queueLabel = SKLabelNode(fontNamed: "Menlo")
    private var messageLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var missionTitleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var missionDetailLabel = SKLabelNode(fontNamed: "Menlo")
    private var forcesLabel = SKLabelNode(fontNamed: "Menlo")
    private var aiStatusLabel = SKLabelNode(fontNamed: "Menlo")
    private var selectionInfoTitleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var selectionInfoRowLabels: [SKLabelNode] = []
    private var hudButtonFrames: [HudAction: CGRect] = [:]
    private var hudButtonSubtitleLabels: [HudAction: SKLabelNode] = [:]
    private var hudButtonShapes: [HudAction: SKShapeNode] = [:]
    private var hudPage: HudPage = .tactical
    private var hudPageFrames: [HudPage: CGRect] = [:]
    private var hudPageShapes: [HudPage: SKShapeNode] = [:]
    private var minimapFrame = CGRect.zero
    private var minimapBlipsNode = SKNode()
    private var minimapCameraBox = SKShapeNode(rectOf: CGSize(width: 36, height: 24), cornerRadius: 2)

    private var touchStartScene: CGPoint?
    private var touchStartWorld: CGPoint?
    private var panStartCamera: CGPoint?
    private var pinchStartDistance: CGFloat?
    private var pinchStartScale: CGFloat = 1.0
    private var isPanning = false
    private var isUsingMinimap = false
    private var touchStartedOnEntity = false
    private var touchStartedOnPlayerEntity = false
    private var isBoxSelecting = false
    private var selectionBoxNode: SKShapeNode?
    private let minCameraScale: CGFloat = 0.72
    private let maxCameraScale: CGFloat = 1.58
    private let controlPointVisionTiles = 6
    private let structureBuildCoverageRadius: CGFloat = 390
    private let controlPointBuildCoverageRadius: CGFloat = 180
    private let controlPointNoBuildRadius: CGFloat = 56
    private let controlPointCaptureBonus = 260
    private let holdEngagementRadius: CGFloat = 340
    private let holdReturnTolerance: CGFloat = 58
    private let attackMoveEngagementRadius: CGFloat = 285
    private let highValueNavalEscortRadius: CGFloat = 620
    private let carrierGuardWingRequirement = 2
    private let carrierGuardThreatRadius: CGFloat = 430
    private let carrierGuardStationReanchorTolerance: CGFloat = 24
    private let mechanicRepairRange: CGFloat = 95
    private let mechanicRepairPerSecond: CGFloat = 22
    private let controlGroupRecallDelay: TimeInterval = 0.24
    private let airFormationSpacing: CGFloat = 84
    private let airSeparationRadius: CGFloat = 76
    private let airSeparationWeight: CGFloat = 0.68
    private let airAttackStationRadius: CGFloat = 104
    private let isCICaptureMode = ProcessInfo.processInfo.environment["DESERT_CI_CAPTURE_MODE"] == "1"

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(white: 0.04, alpha: 1.0)
        view.isMultipleTouchEnabled = true
        if isCICaptureMode,
           let rawPage = ProcessInfo.processInfo.environment["DESERT_CI_HUD_PAGE"],
           let ciPage = HudPage(rawValue: rawPage) {
            hudPage = ciPage
        }

        addChild(worldNode)
        worldNode.addChild(mapNode)
        worldNode.addChild(entityLayer)
        worldNode.addChild(effectsLayer)
        effectsLayer.addChild(focusFireMarkerNode)
        focusFireMarkerNode.zPosition = 20
        focusFireMarkerNode.isHidden = true
        worldNode.addChild(fogLayer)

        camera = cameraRig
        addChild(cameraRig)
        cameraRig.addChild(hudNode)
        cameraRig.position = initialCameraPosition()

        mapNode.zPosition = 0
        entityLayer.zPosition = 100
        effectsLayer.zPosition = 190
        fogLayer.zPosition = 300
        hudNode.zPosition = 1000

        buildTerrain()
        drawMap()
        spawnControlPoints()
        spawnInitialForces()
        layoutHUD()
        updateFog(force: true)
        prepareCICaptureScene()
        updateHUD()
        showMessage("Capture oil and flags, secure the coast, build combined forces, destroy the enemy HQ.", color: .white)
    }

    private func initialCameraPosition() -> CGPoint {
        if ProcessInfo.processInfo.environment["DESERT_CI_CAMERA_FOCUS"] == "air" {
            return tileCenter(TileCoord(row: 15, col: 16))
        }
        if ProcessInfo.processInfo.environment["DESERT_CI_CAMERA_FOCUS"] == "land" {
            return tileCenter(TileCoord(row: 15, col: 13))
        }
        if ProcessInfo.processInfo.environment["DESERT_CI_CAMERA_FOCUS"] == "coast" {
            return tileCenter(TileCoord(row: 17, col: 21))
        }
        return tileCenter(TileCoord(row: 12, col: 14))
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard !terrain.isEmpty else { return }
        cameraRig.position = clampCamera(cameraRig.position)
        layoutHUD()
    }

    override func update(_ currentTime: TimeInterval) {
        if isCICaptureMode {
            lastUpdateTime = currentTime
            updateHUD()
            return
        }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }

        let dt = min(currentTime - lastUpdateTime, 0.1)
        lastUpdateTime = currentTime

        guard victoryState == nil else {
            updateHUD()
            return
        }

        updateConstruction(dt: dt)
        updateBuildOrders(dt: dt)
        updateSupportCooldowns(dt: dt)
        updateEconomy(dt: dt)
        updateCapture(dt: dt)
        updateControlPointCapture(dt: dt)
        updateRepair(dt: dt)
        updateMovement(dt: dt)
        updateCombat(dt: dt)
        updateAI(dt: dt)
        updateFog(force: false, dt: dt)
        cullDestroyedEntities()
        updateMissionProgress()
        updateVictoryState()
        updateHUD()
    }

    private func buildTerrain() {
        terrain = Array(repeating: Array(repeating: .sand, count: cols), count: rows)
        for row in 0..<rows {
            for col in 0..<cols {
                let tile = TileCoord(row: row, col: col)
                if isWaterCoordinate(tile) {
                    terrain[row][col] = .water
                } else if isRoadCoordinate(tile) {
                    terrain[row][col] = .road
                } else if isRidgeCoordinate(tile) {
                    terrain[row][col] = .ridge
                } else if isOilCoordinate(tile) {
                    terrain[row][col] = .oil
                }
            }
        }
    }

    private func isWaterCoordinate(_ tile: TileCoord) -> Bool {
        if tile.col >= 25 && tile.row >= 4 { return true }
        if tile.col >= 22 && tile.row >= 16 { return true }
        if tile.col >= 27 { return true }
        if tile.row >= 21 && tile.col >= 18 { return true }
        return false
    }

    private func isRoadCoordinate(_ tile: TileCoord) -> Bool {
        if tile.row == 14 && tile.col >= 2 && tile.col <= 23 { return true }
        if tile.col == 7 && tile.row >= 5 && tile.row <= 20 { return true }
        if tile.row == 8 && tile.col >= 7 && tile.col <= 24 { return true }
        if tile.col == 18 && tile.row >= 5 && tile.row <= 18 { return true }
        if abs(tile.row - tile.col + 2) <= 0 && tile.row >= 4 && tile.row <= 18 { return true }
        if skirmishSeed % 3 == 1 && tile.row == 11 && tile.col >= 5 && tile.col <= 23 { return true }
        if skirmishSeed % 3 == 2 && tile.col == 12 && tile.row >= 3 && tile.row <= 18 { return true }
        return false
    }

    private func isRidgeCoordinate(_ tile: TileCoord) -> Bool {
        let ridges = [
            TileCoord(row: 4, col: 5), TileCoord(row: 5, col: 5), TileCoord(row: 6, col: 4),
            TileCoord(row: 17, col: 3), TileCoord(row: 18, col: 3), TileCoord(row: 19, col: 4),
            TileCoord(row: 11, col: 13), TileCoord(row: 12, col: 13), TileCoord(row: 10, col: 14),
            TileCoord(row: 18, col: 15), TileCoord(row: 19, col: 15)
        ]
        let variantRidges: [TileCoord]
        switch skirmishSeed % 3 {
        case 1:
            variantRidges = [TileCoord(row: 7, col: 10), TileCoord(row: 8, col: 10), TileCoord(row: 15, col: 18)]
        case 2:
            variantRidges = [TileCoord(row: 9, col: 8), TileCoord(row: 10, col: 8), TileCoord(row: 13, col: 21)]
        default:
            variantRidges = []
        }
        return ridges.contains(tile) || variantRidges.contains(tile)
    }

    private func isOilCoordinate(_ tile: TileCoord) -> Bool {
        let oilTiles = [playerOilTile(), enemyOilTile()] + neutralOilTiles()
        return oilTiles.contains(tile)
    }

    private func playerOilTile() -> TileCoord {
        switch skirmishSeed % 3 {
        case 1: return TileCoord(row: 15, col: 6)
        case 2: return TileCoord(row: 17, col: 6)
        default: return TileCoord(row: 16, col: 5)
        }
    }

    private func enemyOilTile() -> TileCoord {
        switch skirmishSeed % 3 {
        case 1: return TileCoord(row: 6, col: 21)
        case 2: return TileCoord(row: 5, col: 22)
        default: return TileCoord(row: 5, col: 21)
        }
    }

    private func neutralOilTiles() -> [TileCoord] {
        switch skirmishSeed % 3 {
        case 1:
            return [TileCoord(row: 10, col: 9), TileCoord(row: 12, col: 17), TileCoord(row: 6, col: 13), TileCoord(row: 18, col: 19)]
        case 2:
            return [TileCoord(row: 12, col: 9), TileCoord(row: 10, col: 16), TileCoord(row: 7, col: 11), TileCoord(row: 16, col: 20)]
        default:
            return [TileCoord(row: 11, col: 10), TileCoord(row: 12, col: 16), TileCoord(row: 6, col: 12), TileCoord(row: 17, col: 20)]
        }
    }

    private func drawMap() {
        mapNode.removeAllChildren()
        fogLayer.removeAllChildren()
        fogNodes.removeAll()

        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxX = -CGFloat.greatestFiniteMagnitude
        var maxY = -CGFloat.greatestFiniteMagnitude

        for row in 0..<rows {
            for col in 0..<cols {
                let tile = TileCoord(row: row, col: col)
                let center = tileCenter(tile)
                minX = min(minX, center.x - tileWidth / 2)
                maxX = max(maxX, center.x + tileWidth / 2)
                minY = min(minY, center.y - tileHeight / 2)
                maxY = max(maxY, center.y + tileHeight / 2)

                let shape = SKShapeNode(path: diamondPath(width: tileWidth, height: tileHeight))
                shape.position = center
                shape.lineWidth = 1
                shape.strokeColor = UIColor(red: 0.55, green: 0.48, blue: 0.34, alpha: 0.55)
                shape.fillColor = color(for: terrain[row][col])
                shape.zPosition = zPosition(for: center)
                mapNode.addChild(shape)

                addTerrainDetail(for: tile, terrain: terrain[row][col], at: center)
                addScenery(for: tile, terrain: terrain[row][col], at: center)

                let fog = SKShapeNode(path: diamondPath(width: tileWidth + 1, height: tileHeight + 1))
                fog.position = center
                fog.fillColor = UIColor.black
                fog.strokeColor = .clear
                fog.alpha = 0.86
                fog.zPosition = zPosition(for: center) + 1000
                fogLayer.addChild(fog)
                fogNodes[tile] = fog
            }
        }

        worldBounds = CGRect(x: minX - 120, y: minY - 120, width: maxX - minX + 240, height: maxY - minY + 240)
    }

    private func color(for terrain: Terrain) -> UIColor {
        switch terrain {
        case .sand:
            UIColor(red: 0.82, green: 0.70, blue: 0.45, alpha: 1.0)
        case .road:
            UIColor(red: 0.55, green: 0.54, blue: 0.47, alpha: 1.0)
        case .water:
            UIColor(red: 0.07, green: 0.55, blue: 0.65, alpha: 1.0)
        case .oil:
            UIColor(red: 0.70, green: 0.62, blue: 0.40, alpha: 1.0)
        case .ridge:
            UIColor(red: 0.42, green: 0.37, blue: 0.31, alpha: 1.0)
        }
    }

    private func addTerrainDetail(for tile: TileCoord, terrain: Terrain, at center: CGPoint) {
        switch terrain {
        case .water:
            let shoreSegments = shorelineSegments(for: tile)
            if !shoreSegments.isEmpty {
                let shallowWater = SKShapeNode(
                    path: diamondPath(width: tileWidth - 5, height: tileHeight - 3)
                )
                shallowWater.position = center
                shallowWater.fillColor = UIColor(red: 0.12, green: 0.72, blue: 0.68, alpha: 0.34)
                shallowWater.strokeColor = .clear
                shallowWater.zPosition = zPosition(for: center) + 0.12
                mapNode.addChild(shallowWater)

                for segment in shoreSegments {
                    let start = CGPoint(x: segment.start.x * 0.88, y: segment.start.y * 0.88)
                    let end = CGPoint(x: segment.end.x * 0.88, y: segment.end.y * 0.88)
                    let path = CGMutablePath()
                    path.move(to: start)
                    path.addLine(to: end)

                    let wash = SKShapeNode(path: path)
                    wash.position = center
                    wash.strokeColor = UIColor(red: 0.62, green: 0.94, blue: 0.86, alpha: 0.32)
                    wash.lineWidth = 7
                    wash.lineCap = .round
                    wash.zPosition = zPosition(for: center) + 0.22
                    mapNode.addChild(wash)

                    let foam = SKShapeNode(path: path)
                    foam.position = center
                    foam.strokeColor = UIColor.white.withAlphaComponent(0.72)
                    foam.lineWidth = 2
                    foam.lineCap = .round
                    foam.zPosition = zPosition(for: center) + 0.26
                    mapNode.addChild(foam)
                }
            } else if (tile.row + tile.col) % 3 == 0 {
                let wave = SKShapeNode(rectOf: CGSize(width: 28, height: 2), cornerRadius: 1)
                wave.position = center + CGPoint(x: 2, y: CGFloat((tile.row % 3) - 1) * 5)
                wave.fillColor = UIColor.white.withAlphaComponent(0.25)
                wave.strokeColor = .clear
                wave.zRotation = (tile.row + tile.col) % 2 == 0 ? -0.42 : 0.42
                wave.zPosition = zPosition(for: center) + 0.2
                mapNode.addChild(wave)
            }
        case .road:
            let dash = SKShapeNode(rectOf: CGSize(width: 26, height: 3), cornerRadius: 1)
            dash.position = center
            dash.fillColor = UIColor(white: 0.78, alpha: 0.45)
            dash.strokeColor = .clear
            dash.zRotation = -0.45
            dash.zPosition = zPosition(for: center) + 0.3
            mapNode.addChild(dash)
        case .oil:
            let stain = SKShapeNode(ellipseOf: CGSize(width: 22, height: 11))
            stain.position = center
            stain.fillColor = UIColor.black.withAlphaComponent(0.38)
            stain.strokeColor = .clear
            stain.zPosition = zPosition(for: center) + 0.4
            mapNode.addChild(stain)
        case .ridge:
            for index in 0..<3 {
                let rock = SKShapeNode(path: trianglePath(size: CGFloat(16 + index * 6)))
                rock.position = center + CGPoint(x: CGFloat(index - 1) * 14, y: CGFloat(index % 2) * 6)
                rock.fillColor = UIColor(red: 0.32, green: 0.30, blue: 0.28, alpha: 1.0)
                rock.strokeColor = UIColor(white: 0.18, alpha: 1.0)
                rock.zPosition = zPosition(for: center) + CGFloat(index) * 0.1 + 0.5
                mapNode.addChild(rock)
            }
        case .sand:
            if (tile.row * 7 + tile.col * 11) % 17 == 0 {
                let shrub = SKShapeNode(ellipseOf: CGSize(width: 14, height: 8))
                shrub.position = center + CGPoint(x: -12, y: 2)
                shrub.fillColor = UIColor(red: 0.16, green: 0.42, blue: 0.20, alpha: 0.78)
                shrub.strokeColor = .clear
                shrub.zPosition = zPosition(for: center) + 0.5
                mapNode.addChild(shrub)
            }
        }
    }

    private func shorelineSegments(for tile: TileCoord) -> [(start: CGPoint, end: CGPoint)] {
        guard terrain(at: tile) == .water else { return [] }

        let top = CGPoint(x: 0, y: tileHeight / 2)
        let right = CGPoint(x: tileWidth / 2, y: 0)
        let bottom = CGPoint(x: 0, y: -tileHeight / 2)
        let left = CGPoint(x: -tileWidth / 2, y: 0)
        let edges: [(neighbor: TileCoord, start: CGPoint, end: CGPoint)] = [
            (neighbor: TileCoord(row: tile.row - 1, col: tile.col), start: top, end: right),
            (neighbor: TileCoord(row: tile.row, col: tile.col + 1), start: right, end: bottom),
            (neighbor: TileCoord(row: tile.row + 1, col: tile.col), start: bottom, end: left),
            (neighbor: TileCoord(row: tile.row, col: tile.col - 1), start: left, end: top)
        ]

        return edges.compactMap { edge in
            guard isValid(edge.neighbor), terrain(at: edge.neighbor) != .water else { return nil }
            return (start: edge.start, end: edge.end)
        }
    }

    private func addScenery(for tile: TileCoord, terrain: Terrain, at center: CGPoint) {
        guard let kind = sceneryKind(for: tile, terrain: terrain) else { return }
        let node = SKNode()
        node.position = center
        node.zPosition = zPosition(for: center) + 0.8

        switch kind {
        case .village:
            addVillageScenery(to: node, tile: tile)
        case .oasis:
            addOasisScenery(to: node, tile: tile)
        case .farm:
            addFarmScenery(to: node, tile: tile)
        case .depot:
            addDepotScenery(to: node, tile: tile)
        case .wreck:
            addWreckScenery(to: node, tile: tile)
        }

        mapNode.addChild(node)
    }

    private func sceneryKind(for tile: TileCoord, terrain: Terrain) -> SceneryKind? {
        guard terrain == .sand || terrain == .road else { return nil }

        let baseVillages = [
            TileCoord(row: 10, col: 5), TileCoord(row: 12, col: 7), TileCoord(row: 14, col: 11),
            TileCoord(row: 6, col: 16), TileCoord(row: 9, col: 19), TileCoord(row: 17, col: 10),
            TileCoord(row: 18, col: 6)
        ]
        let baseOases = [
            TileCoord(row: 11, col: 8), TileCoord(row: 15, col: 13), TileCoord(row: 7, col: 22),
            TileCoord(row: 18, col: 18)
        ]
        let baseFarms = [
            TileCoord(row: 13, col: 6), TileCoord(row: 16, col: 12), TileCoord(row: 6, col: 19)
        ]
        let baseDepots = [
            TileCoord(row: 14, col: 4), TileCoord(row: 8, col: 18), TileCoord(row: 17, col: 20)
        ]
        let baseWrecks = [
            TileCoord(row: 9, col: 10), TileCoord(row: 12, col: 14), TileCoord(row: 15, col: 18)
        ]

        let variantVillages: [TileCoord]
        let variantOases: [TileCoord]
        let variantFarms: [TileCoord]
        let variantDepots: [TileCoord]
        let variantWrecks: [TileCoord]
        switch skirmishSeed % 3 {
        case 1:
            variantVillages = [TileCoord(row: 9, col: 7), TileCoord(row: 16, col: 16)]
            variantOases = [TileCoord(row: 12, col: 19), TileCoord(row: 18, col: 12)]
            variantFarms = [TileCoord(row: 11, col: 11)]
            variantDepots = [TileCoord(row: 6, col: 23)]
            variantWrecks = [TileCoord(row: 13, col: 21)]
        case 2:
            variantVillages = [TileCoord(row: 8, col: 13), TileCoord(row: 15, col: 9)]
            variantOases = [TileCoord(row: 10, col: 18), TileCoord(row: 19, col: 13)]
            variantFarms = [TileCoord(row: 17, col: 15)]
            variantDepots = [TileCoord(row: 7, col: 20)]
            variantWrecks = [TileCoord(row: 13, col: 11)]
        default:
            variantVillages = []
            variantOases = []
            variantFarms = []
            variantDepots = []
            variantWrecks = []
        }

        if (baseVillages + variantVillages).contains(tile) { return .village }
        if (baseOases + variantOases).contains(tile) { return .oasis }
        if (baseFarms + variantFarms).contains(tile) { return .farm }
        if (baseDepots + variantDepots).contains(tile) { return .depot }
        if (baseWrecks + variantWrecks).contains(tile) { return .wreck }
        return nil
    }

    private func addVillageScenery(to node: SKNode, tile: TileCoord) {
        let offsets = [
            CGPoint(x: -19, y: -2), CGPoint(x: 3, y: 8), CGPoint(x: 21, y: -4),
            CGPoint(x: -2, y: -12)
        ]
        for (index, offset) in offsets.enumerated() {
            let width = CGFloat(17 + (tile.row + index) % 3 * 4)
            let height = CGFloat(13 + (tile.col + index) % 2 * 5)
            let house = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 2)
            house.position = offset
            house.fillColor = UIColor(red: 0.72, green: 0.68, blue: 0.59, alpha: 1.0)
            house.strokeColor = UIColor(red: 0.38, green: 0.32, blue: 0.24, alpha: 1.0)
            house.lineWidth = 1.2
            house.zPosition = CGFloat(index) * 0.05
            node.addChild(house)

            let roof = SKShapeNode(rectOf: CGSize(width: width * 0.86, height: 4), cornerRadius: 1)
            roof.position = offset + CGPoint(x: 0, y: height * 0.32)
            roof.fillColor = UIColor(red: 0.53, green: 0.43, blue: 0.33, alpha: 1.0)
            roof.strokeColor = .clear
            roof.zPosition = house.zPosition + 0.01
            node.addChild(roof)
        }

        let alley = SKShapeNode(rectOf: CGSize(width: 54, height: 4), cornerRadius: 1)
        alley.position = CGPoint(x: 0, y: -1)
        alley.fillColor = UIColor(red: 0.42, green: 0.39, blue: 0.33, alpha: 0.58)
        alley.strokeColor = .clear
        alley.zRotation = -0.45
        alley.zPosition = -0.1
        node.addChild(alley)
    }

    private func addOasisScenery(to node: SKNode, tile: TileCoord) {
        let pool = SKShapeNode(ellipseOf: CGSize(width: 34, height: 15))
        pool.position = CGPoint(x: 0, y: -4)
        pool.fillColor = UIColor(red: 0.06, green: 0.55, blue: 0.64, alpha: 0.72)
        pool.strokeColor = UIColor(red: 0.53, green: 0.80, blue: 0.65, alpha: 0.85)
        pool.lineWidth = 1
        pool.zPosition = -0.2
        node.addChild(pool)

        let palmOffsets = [
            CGPoint(x: -22, y: 5), CGPoint(x: -8, y: 13), CGPoint(x: 18, y: 6),
            CGPoint(x: 7, y: -13)
        ]
        for (index, offset) in palmOffsets.enumerated() {
            addPalm(to: node, at: offset, scale: 0.85 + CGFloat((tile.row + tile.col + index) % 3) * 0.08)
        }
    }

    private func addPalm(to node: SKNode, at offset: CGPoint, scale: CGFloat) {
        let trunk = SKShapeNode(rectOf: CGSize(width: 4 * scale, height: 18 * scale), cornerRadius: 1)
        trunk.position = offset + CGPoint(x: 0, y: 4 * scale)
        trunk.fillColor = UIColor(red: 0.48, green: 0.31, blue: 0.18, alpha: 1.0)
        trunk.strokeColor = .clear
        trunk.zRotation = -0.18
        node.addChild(trunk)

        for angle in stride(from: 0.0, to: Double.pi * 2, by: Double.pi / 3) {
            let leaf = SKShapeNode(ellipseOf: CGSize(width: 19 * scale, height: 6 * scale))
            leaf.position = offset + CGPoint(x: cos(CGFloat(angle)) * 7 * scale, y: 15 * scale + sin(CGFloat(angle)) * 4 * scale)
            leaf.fillColor = UIColor(red: 0.11, green: 0.43, blue: 0.20, alpha: 0.96)
            leaf.strokeColor = .clear
            leaf.zRotation = CGFloat(angle)
            leaf.zPosition = 0.2
            node.addChild(leaf)
        }
    }

    private func addFarmScenery(to node: SKNode, tile: TileCoord) {
        for index in 0..<4 {
            let strip = SKShapeNode(rectOf: CGSize(width: 43, height: 4), cornerRadius: 1)
            strip.position = CGPoint(x: 0, y: CGFloat(index - 2) * 6)
            strip.fillColor = index % 2 == 0
                ? UIColor(red: 0.36, green: 0.52, blue: 0.22, alpha: 0.78)
                : UIColor(red: 0.58, green: 0.48, blue: 0.26, alpha: 0.78)
            strip.strokeColor = .clear
            strip.zRotation = -0.45
            strip.zPosition = CGFloat(index) * 0.03
            node.addChild(strip)
        }

        let hut = SKShapeNode(rectOf: CGSize(width: 18, height: 12), cornerRadius: 2)
        hut.position = CGPoint(x: -22, y: 11)
        hut.fillColor = UIColor(red: 0.66, green: 0.58, blue: 0.44, alpha: 1.0)
        hut.strokeColor = UIColor(red: 0.35, green: 0.28, blue: 0.20, alpha: 1.0)
        hut.lineWidth = 1
        hut.zPosition = 0.3
        node.addChild(hut)

        if (tile.row + tile.col) % 2 == 0 {
            addPalm(to: node, at: CGPoint(x: 24, y: 10), scale: 0.7)
        }
    }

    private func addDepotScenery(to node: SKNode, tile: TileCoord) {
        let pad = SKShapeNode(rectOf: CGSize(width: 56, height: 22), cornerRadius: 2)
        pad.fillColor = UIColor(red: 0.43, green: 0.41, blue: 0.35, alpha: 0.72)
        pad.strokeColor = UIColor(white: 0.18, alpha: 0.8)
        pad.lineWidth = 1
        pad.zRotation = -0.45
        pad.zPosition = -0.2
        node.addChild(pad)

        for index in 0..<3 {
            let crate = SKShapeNode(rectOf: CGSize(width: 13, height: 10), cornerRadius: 1)
            crate.position = CGPoint(x: CGFloat(index - 1) * 16, y: CGFloat((tile.row + index) % 2) * 7 - 3)
            crate.fillColor = UIColor(red: 0.62, green: 0.47, blue: 0.24, alpha: 1.0)
            crate.strokeColor = UIColor(red: 0.27, green: 0.20, blue: 0.12, alpha: 1.0)
            crate.lineWidth = 1
            crate.zPosition = CGFloat(index) * 0.04
            node.addChild(crate)
        }

        let fuel = SKShapeNode(ellipseOf: CGSize(width: 13, height: 18))
        fuel.position = CGPoint(x: 25, y: 6)
        fuel.fillColor = UIColor(red: 0.30, green: 0.34, blue: 0.34, alpha: 1.0)
        fuel.strokeColor = UIColor(white: 0.12, alpha: 1.0)
        fuel.lineWidth = 1
        fuel.zPosition = 0.25
        node.addChild(fuel)
    }

    private func addWreckScenery(to node: SKNode, tile: TileCoord) {
        let scorch = SKShapeNode(ellipseOf: CGSize(width: 52, height: 20))
        scorch.fillColor = UIColor.black.withAlphaComponent(0.25)
        scorch.strokeColor = .clear
        scorch.zPosition = -0.3
        node.addChild(scorch)

        let hull = SKShapeNode(rectOf: CGSize(width: 34, height: 13), cornerRadius: 3)
        hull.position = CGPoint(x: -2, y: -2)
        hull.fillColor = UIColor(red: 0.34, green: 0.29, blue: 0.24, alpha: 1.0)
        hull.strokeColor = UIColor(white: 0.12, alpha: 1.0)
        hull.lineWidth = 1
        hull.zRotation = tile.row % 2 == 0 ? -0.2 : 0.22
        node.addChild(hull)

        let barrel = SKShapeNode(rectOf: CGSize(width: 24, height: 4), cornerRadius: 1)
        barrel.position = CGPoint(x: 18, y: 5)
        barrel.fillColor = UIColor(white: 0.10, alpha: 1.0)
        barrel.strokeColor = .clear
        barrel.zRotation = hull.zRotation
        node.addChild(barrel)

        for index in 0..<3 {
            let debris = SKShapeNode(rectOf: CGSize(width: 6, height: 4), cornerRadius: 1)
            debris.position = CGPoint(x: CGFloat(index - 1) * 15, y: CGFloat((tile.col + index) % 3 - 1) * 7)
            debris.fillColor = UIColor(red: 0.22, green: 0.20, blue: 0.18, alpha: 1.0)
            debris.strokeColor = .clear
            debris.zRotation = CGFloat(index) * 0.4
            node.addChild(debris)
        }
    }

    private func spawnControlPoints() {
        controlPoints.removeAll()

        for (index, spec) in controlPointSpecs().enumerated() {
            let point = BattlefieldControlPoint(id: index + 1, name: spec.name, position: tileCenter(spec.tile))
            configureControlPoint(point)
            controlPoints.append(point)
            entityLayer.addChild(point.node)
        }
    }

    private func controlPointSpecs() -> [(name: String, tile: TileCoord)] {
        switch skirmishSeed % 3 {
        case 1:
            return [
                ("ALPHA", TileCoord(row: 10, col: 8)),
                ("BRAVO", TileCoord(row: 11, col: 16)),
                ("CHARLIE", TileCoord(row: 16, col: 19))
            ]
        case 2:
            return [
                ("ALPHA", TileCoord(row: 12, col: 8)),
                ("BRAVO", TileCoord(row: 9, col: 16)),
                ("CHARLIE", TileCoord(row: 15, col: 20))
            ]
        default:
            return [
                ("ALPHA", TileCoord(row: 12, col: 9)),
                ("BRAVO", TileCoord(row: 10, col: 17)),
                ("CHARLIE", TileCoord(row: 15, col: 18))
            ]
        }
    }

    private func configureControlPoint(_ point: BattlefieldControlPoint) {
        point.node.zPosition = zPosition(for: point.node.position) + 82

        point.ring.fillColor = UIColor.black.withAlphaComponent(0.14)
        point.ring.lineWidth = 3
        point.ring.glowWidth = 1
        point.ring.zPosition = -2
        point.node.addChild(point.ring)

        let pole = SKShapeNode(rectOf: CGSize(width: 4, height: 42), cornerRadius: 1)
        pole.position = CGPoint(x: -8, y: 22)
        pole.fillColor = UIColor(white: 0.92, alpha: 1.0)
        pole.strokeColor = UIColor(white: 0.12, alpha: 1.0)
        pole.lineWidth = 1
        pole.zPosition = 1
        point.node.addChild(pole)

        point.flag.position = CGPoint(x: 6, y: 39)
        point.flag.strokeColor = UIColor.white.withAlphaComponent(0.82)
        point.flag.lineWidth = 1
        point.flag.zPosition = 2
        point.node.addChild(point.flag)

        let base = SKShapeNode(rectOf: CGSize(width: 34, height: 10), cornerRadius: 2)
        base.position = CGPoint(x: -8, y: 0)
        base.fillColor = UIColor(red: 0.32, green: 0.29, blue: 0.23, alpha: 1.0)
        base.strokeColor = UIColor(white: 0.10, alpha: 1.0)
        base.lineWidth = 1
        point.node.addChild(base)

        point.label.fontSize = 9
        point.label.fontColor = .white
        point.label.verticalAlignmentMode = .center
        point.label.horizontalAlignmentMode = .center
        point.label.position = CGPoint(x: 0, y: -31)
        point.node.addChild(point.label)

        point.progressBack.position = CGPoint(x: 0, y: -44)
        point.progressBack.fillColor = UIColor.black.withAlphaComponent(0.72)
        point.progressBack.strokeColor = UIColor.white.withAlphaComponent(0.45)
        point.progressBack.lineWidth = 1
        point.node.addChild(point.progressBack)

        point.progressFill.position = CGPoint(x: -25, y: -44)
        point.progressFill.strokeColor = .clear
        point.node.addChild(point.progressFill)

        updateControlPointVisual(point)
    }

    private func updateControlPointVisual(_ point: BattlefieldControlPoint) {
        let ownerColor = controlPointColor(for: point.faction)
        point.flag.fillColor = ownerColor
        point.ring.strokeColor = ownerColor.withAlphaComponent(0.92)
        point.label.text = "\(point.name) \(controlPointOwnerCode(point.faction))"

        let isCapturing = point.capturingFaction != nil && point.captureProgress > 0
        point.progressBack.isHidden = !isCapturing
        point.progressFill.isHidden = !isCapturing
        guard let capturingFaction = point.capturingFaction, isCapturing else { return }

        let progress = max(0, min(1, point.captureProgress / 4.0))
        point.progressFill.fillColor = controlPointColor(for: capturingFaction)
        point.progressFill.xScale = max(0.04, progress)
        point.progressFill.position = CGPoint(x: -25 + 25 * progress, y: -44)
    }

    private func controlPointColor(for faction: Faction) -> UIColor {
        switch faction {
        case .neutral:
            return UIColor(red: 0.98, green: 0.76, blue: 0.22, alpha: 1.0)
        case .player, .enemy:
            return faction.color
        }
    }

    private func controlPointOwnerCode(_ faction: Faction) -> String {
        switch faction {
        case .player:
            return "BLUE"
        case .enemy:
            return "RED"
        case .neutral:
            return "NEUT"
        }
    }

    private func spawnInitialForces() {
        addEntity(kind: .hq, faction: .player, at: tileCenter(TileCoord(row: 16, col: 7)))
        addEntity(kind: .barracks, faction: .player, at: tileCenter(TileCoord(row: 15, col: 5)))
        addEntity(kind: .airfield, faction: .player, at: tileCenter(TileCoord(row: 13, col: 8)))
        addEntity(kind: .shipyard, faction: .player, at: tileCenter(TileCoord(row: 17, col: 21)))
        addEntity(kind: .oilDerrick, faction: .player, at: tileCenter(playerOilTile()))

        addEntity(kind: .hq, faction: .enemy, at: tileCenter(TileCoord(row: 5, col: 20)))
        addEntity(kind: .barracks, faction: .enemy, at: tileCenter(TileCoord(row: 6, col: 18)))
        addEntity(kind: .airfield, faction: .enemy, at: tileCenter(TileCoord(row: 7, col: 21)))
        addEntity(kind: .shipyard, faction: .enemy, at: tileCenter(TileCoord(row: 8, col: 24)))
        addEntity(kind: .oilDerrick, faction: .enemy, at: tileCenter(enemyOilTile()))

        for tile in neutralOilTiles() {
            addEntity(kind: .oilDerrick, faction: .neutral, at: tileCenter(tile))
        }

        addEntity(kind: .humvee, faction: .player, at: tileCenter(TileCoord(row: 14, col: 7)))
        addEntity(kind: .tank, faction: .player, at: tileCenter(TileCoord(row: 15, col: 8)))
        addEntity(kind: .tank, faction: .player, at: tileCenter(TileCoord(row: 16, col: 9)))
        addEntity(kind: .artillery, faction: .player, at: tileCenter(TileCoord(row: 14, col: 9)))
        addEntity(kind: .mechanic, faction: .player, at: tileCenter(TileCoord(row: 16, col: 6)))
        addEntity(kind: .helicopter, faction: .player, at: tileCenter(TileCoord(row: 13, col: 10)) + CGPoint(x: 0, y: 28))
        addEntity(kind: .battleship, faction: .player, at: tileCenter(TileCoord(row: 18, col: 23)))
        addEntity(kind: .carrier, faction: .player, at: tileCenter(TileCoord(row: 20, col: 23)))

        addEntity(kind: .humvee, faction: .enemy, at: tileCenter(TileCoord(row: 7, col: 19)))
        addEntity(kind: .tank, faction: .enemy, at: tileCenter(TileCoord(row: 7, col: 18)))
        addEntity(kind: .artillery, faction: .enemy, at: tileCenter(TileCoord(row: 8, col: 17)))
        addEntity(kind: .mechanic, faction: .enemy, at: tileCenter(TileCoord(row: 6, col: 19)))
        addEntity(kind: .helicopter, faction: .enemy, at: tileCenter(TileCoord(row: 8, col: 20)) + CGPoint(x: 0, y: 28))
        addEntity(kind: .battleship, faction: .enemy, at: tileCenter(TileCoord(row: 9, col: 25)))
        addEntity(kind: .submarine, faction: .enemy, at: tileCenter(TileCoord(row: 10, col: 26)))
    }

    @discardableResult
    private func addEntity(kind: EntityKind, faction: Faction, at position: CGPoint) -> GameEntity {
        let entity = GameEntity(id: nextEntityID, kind: kind, faction: faction, position: position)
        nextEntityID += 1
        configureEntityNode(entity)
        entity.node.zPosition = entityZPosition(entity)
        entities[entity.id] = entity
        entityLayer.addChild(entity.node)
        return entity
    }

    private func configureEntityNode(_ entity: GameEntity) {
        let base = SKNode()
        entity.node.addChild(base)

        let shadow = SKShapeNode(ellipseOf: CGSize(width: entity.kind.footprint * 1.35, height: entity.kind.footprint * 0.55))
        shadow.fillColor = UIColor.black.withAlphaComponent(0.28)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -6)
        shadow.zPosition = -2
        shadow.isHidden = entity.kind.domain == .air
        base.addChild(shadow)

        switch entity.kind {
        case .hq, .barracks, .airfield, .shipyard, .oilDerrick, .radarOutpost, .sonarBuoy, .guardTower, .samSite, .coastalBattery:
            addStructureBody(for: entity, to: base)
        case .aaTruck, .humvee, .tank, .artillery, .mechanic:
            addLandUnitBody(for: entity, to: base)
        case .helicopter, .fighter:
            addAirUnitBody(for: entity, to: base)
        case .battleship, .submarine, .carrier:
            addNavalUnitBody(for: entity, to: base)
        }

        configureNavalWakeNode(for: entity)
        configureAirShadowNode(for: entity)

        entity.selectionNode.fillColor = UIColor.clear
        entity.selectionNode.strokeColor = UIColor(red: 0.2, green: 1.0, blue: 0.35, alpha: 1.0)
        entity.selectionNode.lineWidth = 3
        entity.selectionNode.isHidden = true
        entity.selectionNode.zPosition = -1
        entity.node.addChild(entity.selectionNode)

        configureSonarCoverageNode(for: entity)
        entity.node.addChild(entity.sonarCoverageNode)
        configureEscortCoverageNode(for: entity)
        entity.node.addChild(entity.escortCoverageNode)
        configureNavalGunRangeNode(for: entity)
        entity.node.addChild(entity.navalGunRangeNode)
        configureRepairCoverageNode(for: entity)
        entity.node.addChild(entity.repairCoverageNode)
        configureCarrierGuardAnchorCoverageNode(for: entity)
        entity.node.addChild(entity.carrierGuardAnchorCoverageNode)
        configureAirDefenseThreatNodes(for: entity)
        entity.node.addChild(entity.airDefenseThreatCoverageNode)
        entity.node.addChild(entity.airDefenseThreatMarkerNode)

        let healthBack = SKShapeNode(rectOf: CGSize(width: entity.kind.footprint, height: 5), cornerRadius: 1)
        healthBack.position = CGPoint(x: 0, y: entity.kind.footprint * 0.52 + 16)
        healthBack.fillColor = UIColor.black.withAlphaComponent(0.65)
        healthBack.strokeColor = .clear
        healthBack.zPosition = 20
        entity.node.addChild(healthBack)

        entity.healthFill.position = healthBack.position
        entity.healthFill.fillColor = UIColor(red: 0.28, green: 0.92, blue: 0.24, alpha: 1.0)
        entity.healthFill.strokeColor = .clear
        entity.healthFill.zPosition = 21
        entity.node.addChild(entity.healthFill)

        entity.teamFlag.fillColor = entity.faction.color
        entity.teamFlag.strokeColor = UIColor.white.withAlphaComponent(0.75)
        entity.teamFlag.lineWidth = 1
        entity.teamFlag.position = CGPoint(x: entity.kind.footprint * 0.35, y: entity.kind.footprint * 0.45 + 5)
        entity.teamFlag.zPosition = 22
        entity.node.addChild(entity.teamFlag)

        entity.label.text = entity.kind.shortCode
        entity.label.fontSize = entity.kind.isStructure ? 10 : 8
        entity.label.fontColor = .white
        entity.label.verticalAlignmentMode = .center
        entity.label.horizontalAlignmentMode = .center
        entity.label.position = CGPoint(x: 0, y: entity.kind.isStructure ? 4 : 0)
        entity.label.zPosition = 23
        entity.node.addChild(entity.label)

        entity.productionNode.zPosition = 30
        entity.node.addChild(entity.productionNode)

        entity.rallyNode.zPosition = 26
        entity.rallyNode.isHidden = true
        entity.node.addChild(entity.rallyNode)

        entity.commandIntentNode.zPosition = 25
        entity.commandIntentNode.isHidden = true
        entity.node.addChild(entity.commandIntentNode)

        entity.veterancyNode.position = CGPoint(x: 0, y: entity.kind.footprint * 0.52 + 30)
        entity.veterancyNode.zPosition = 27
        entity.node.addChild(entity.veterancyNode)
        updateVeterancyBadge(for: entity)

        entity.captureNode.zPosition = 29
        entity.node.addChild(entity.captureNode)

        entity.constructionNode.zPosition = 31
        entity.node.addChild(entity.constructionNode)
    }

    private func addStructureBody(for entity: GameEntity, to base: SKNode) {
        switch entity.kind {
        case .hq:
            let body = SKShapeNode(rectOf: CGSize(width: 66, height: 42), cornerRadius: 5)
            body.fillColor = UIColor(red: 0.70, green: 0.67, blue: 0.60, alpha: 1.0)
            body.strokeColor = UIColor(white: 0.22, alpha: 1.0)
            body.lineWidth = 2
            base.addChild(body)

            let roof = SKShapeNode(rectOf: CGSize(width: 42, height: 16), cornerRadius: 3)
            roof.position = CGPoint(x: 2, y: 14)
            roof.fillColor = entity.faction.color
            roof.strokeColor = .clear
            base.addChild(roof)

            let antenna = SKShapeNode(rectOf: CGSize(width: 4, height: 32), cornerRadius: 1)
            antenna.position = CGPoint(x: -22, y: 30)
            antenna.fillColor = UIColor(white: 0.15, alpha: 1.0)
            antenna.strokeColor = .clear
            base.addChild(antenna)
        case .barracks:
            let body = SKShapeNode(rectOf: CGSize(width: 62, height: 34), cornerRadius: 4)
            body.fillColor = UIColor(red: 0.58, green: 0.55, blue: 0.49, alpha: 1.0)
            body.strokeColor = UIColor(white: 0.22, alpha: 1.0)
            body.lineWidth = 2
            base.addChild(body)

            let door = SKShapeNode(rectOf: CGSize(width: 24, height: 12), cornerRadius: 2)
            door.position = CGPoint(x: 0, y: -5)
            door.fillColor = UIColor(white: 0.18, alpha: 1.0)
            door.strokeColor = .clear
            base.addChild(door)
        case .airfield:
            let runway = SKShapeNode(rectOf: CGSize(width: 82, height: 22), cornerRadius: 2)
            runway.fillColor = UIColor(red: 0.28, green: 0.30, blue: 0.32, alpha: 1.0)
            runway.strokeColor = UIColor(white: 0.16, alpha: 1.0)
            runway.lineWidth = 2
            base.addChild(runway)

            let stripe = SKShapeNode(rectOf: CGSize(width: 60, height: 3), cornerRadius: 1)
            stripe.fillColor = UIColor.white.withAlphaComponent(0.65)
            stripe.strokeColor = .clear
            base.addChild(stripe)
        case .shipyard:
            let dock = SKShapeNode(rectOf: CGSize(width: 72, height: 28), cornerRadius: 3)
            dock.fillColor = UIColor(red: 0.45, green: 0.39, blue: 0.29, alpha: 1.0)
            dock.strokeColor = UIColor(white: 0.18, alpha: 1.0)
            dock.lineWidth = 2
            base.addChild(dock)

            let crane = SKShapeNode(rectOf: CGSize(width: 10, height: 38), cornerRadius: 1)
            crane.position = CGPoint(x: 24, y: 16)
            crane.fillColor = UIColor(red: 0.86, green: 0.67, blue: 0.22, alpha: 1.0)
            crane.strokeColor = .clear
            base.addChild(crane)
        case .oilDerrick:
            let tower = SKShapeNode(path: derrickPath())
            tower.fillColor = UIColor(red: 0.16, green: 0.14, blue: 0.12, alpha: 1.0)
            tower.strokeColor = UIColor(red: 0.95, green: 0.76, blue: 0.24, alpha: 1.0)
            tower.lineWidth = 2
            base.addChild(tower)

            let pump = SKShapeNode(rectOf: CGSize(width: 36, height: 8), cornerRadius: 2)
            pump.position = CGPoint(x: 5, y: 19)
            pump.fillColor = entity.faction.color
            pump.strokeColor = .clear
            pump.zRotation = -0.35
            base.addChild(pump)
        case .radarOutpost:
            let pad = SKShapeNode(rectOf: CGSize(width: 54, height: 30), cornerRadius: 4)
            pad.fillColor = UIColor(red: 0.46, green: 0.49, blue: 0.47, alpha: 1.0)
            pad.strokeColor = UIColor(white: 0.18, alpha: 1.0)
            pad.lineWidth = 2
            base.addChild(pad)

            let tower = SKShapeNode(rectOf: CGSize(width: 10, height: 30), cornerRadius: 2)
            tower.position = CGPoint(x: -4, y: 15)
            tower.fillColor = UIColor(red: 0.28, green: 0.30, blue: 0.32, alpha: 1.0)
            tower.strokeColor = UIColor(white: 0.12, alpha: 1.0)
            tower.lineWidth = 1.5
            base.addChild(tower)

            let dish = SKShapeNode(ellipseOf: CGSize(width: 34, height: 18))
            dish.position = CGPoint(x: 10, y: 31)
            dish.fillColor = UIColor(red: 0.78, green: 0.84, blue: 0.82, alpha: 1.0)
            dish.strokeColor = UIColor(white: 0.18, alpha: 1.0)
            dish.lineWidth = 2
            dish.zRotation = -0.24
            base.addChild(dish)

            let sweep = SKShapeNode(rectOf: CGSize(width: 28, height: 3), cornerRadius: 1)
            sweep.position = CGPoint(x: 16, y: 33)
            sweep.fillColor = entity.faction.color
            sweep.strokeColor = .clear
            sweep.zRotation = -0.24
            base.addChild(sweep)

            let console = SKShapeNode(rectOf: CGSize(width: 22, height: 10), cornerRadius: 2)
            console.position = CGPoint(x: -12, y: 4)
            console.fillColor = entity.faction.color
            console.strokeColor = .clear
            base.addChild(console)
        case .sonarBuoy:
            let pad = SKShapeNode(ellipseOf: CGSize(width: 50, height: 24))
            pad.fillColor = UIColor(red: 0.31, green: 0.38, blue: 0.39, alpha: 1.0)
            pad.strokeColor = UIColor(white: 0.14, alpha: 1.0)
            pad.lineWidth = 2
            base.addChild(pad)

            let mast = SKShapeNode(rectOf: CGSize(width: 7, height: 32), cornerRadius: 2)
            mast.position = CGPoint(x: -2, y: 18)
            mast.fillColor = UIColor(red: 0.70, green: 0.76, blue: 0.73, alpha: 1.0)
            mast.strokeColor = UIColor(white: 0.16, alpha: 1.0)
            mast.lineWidth = 1.5
            base.addChild(mast)

            let receiver = SKShapeNode(ellipseOf: CGSize(width: 26, height: 12))
            receiver.position = CGPoint(x: 8, y: 34)
            receiver.fillColor = UIColor(red: 0.62, green: 0.80, blue: 0.84, alpha: 1.0)
            receiver.strokeColor = UIColor(white: 0.14, alpha: 1.0)
            receiver.lineWidth = 1.5
            receiver.zRotation = -0.18
            base.addChild(receiver)

            let beacon = SKShapeNode(circleOfRadius: 5)
            beacon.position = CGPoint(x: -11, y: 36)
            beacon.fillColor = entity.faction.color
            beacon.strokeColor = UIColor.white.withAlphaComponent(0.72)
            beacon.lineWidth = 1
            base.addChild(beacon)

            for index in 0..<2 {
                let ring = SKShapeNode(ellipseOf: CGSize(width: 34 + index * 16, height: 14 + index * 8))
                ring.position = CGPoint(x: 3, y: 2)
                ring.fillColor = .clear
                ring.strokeColor = entity.faction.color.withAlphaComponent(index == 0 ? 0.55 : 0.35)
                ring.lineWidth = 1.5
                base.addChild(ring)
            }
        case .guardTower:
            let pad = SKShapeNode(rectOf: CGSize(width: 54, height: 30), cornerRadius: 4)
            pad.fillColor = UIColor(red: 0.43, green: 0.43, blue: 0.39, alpha: 1.0)
            pad.strokeColor = UIColor(white: 0.17, alpha: 1.0)
            pad.lineWidth = 2
            base.addChild(pad)

            let tower = SKShapeNode(rectOf: CGSize(width: 24, height: 30), cornerRadius: 3)
            tower.position = CGPoint(x: -4, y: 12)
            tower.fillColor = UIColor(red: 0.56, green: 0.56, blue: 0.50, alpha: 1.0)
            tower.strokeColor = UIColor(white: 0.18, alpha: 1.0)
            tower.lineWidth = 1.5
            base.addChild(tower)

            let turret = SKShapeNode(ellipseOf: CGSize(width: 30, height: 18))
            turret.position = CGPoint(x: 4, y: 29)
            turret.fillColor = UIColor(red: 0.34, green: 0.35, blue: 0.34, alpha: 1.0)
            turret.strokeColor = UIColor(white: 0.12, alpha: 1.0)
            turret.lineWidth = 1.5
            base.addChild(turret)

            let barrel = SKShapeNode(rectOf: CGSize(width: 30, height: 5), cornerRadius: 2)
            barrel.position = CGPoint(x: 24, y: 30)
            barrel.fillColor = UIColor(white: 0.10, alpha: 1.0)
            barrel.strokeColor = .clear
            base.addChild(barrel)

            let trim = SKShapeNode(rectOf: CGSize(width: 34, height: 6), cornerRadius: 1.5)
            trim.position = CGPoint(x: 0, y: 6)
            trim.fillColor = entity.faction.color
            trim.strokeColor = .clear
            base.addChild(trim)

            let beacon = SKShapeNode(circleOfRadius: 4)
            beacon.position = CGPoint(x: -9, y: 34)
            beacon.fillColor = entity.faction.color
            beacon.strokeColor = UIColor.white.withAlphaComponent(0.72)
            beacon.lineWidth = 1
            base.addChild(beacon)
        case .samSite:
            let pad = SKShapeNode(rectOf: CGSize(width: 56, height: 30), cornerRadius: 4)
            pad.fillColor = UIColor(red: 0.37, green: 0.40, blue: 0.37, alpha: 1.0)
            pad.strokeColor = UIColor(white: 0.15, alpha: 1.0)
            pad.lineWidth = 2
            base.addChild(pad)

            let radar = SKShapeNode(ellipseOf: CGSize(width: 22, height: 12))
            radar.position = CGPoint(x: -16, y: 17)
            radar.fillColor = UIColor(red: 0.75, green: 0.83, blue: 0.78, alpha: 1.0)
            radar.strokeColor = UIColor(white: 0.12, alpha: 1.0)
            radar.lineWidth = 1.5
            radar.zRotation = -0.22
            base.addChild(radar)

            let launcher = SKShapeNode(rectOf: CGSize(width: 34, height: 10), cornerRadius: 2)
            launcher.position = CGPoint(x: 9, y: 17)
            launcher.fillColor = UIColor(red: 0.48, green: 0.51, blue: 0.46, alpha: 1.0)
            launcher.strokeColor = UIColor(white: 0.12, alpha: 1.0)
            launcher.lineWidth = 1.5
            launcher.zRotation = 0.34
            base.addChild(launcher)

            let missileA = SKShapeNode(rectOf: CGSize(width: 26, height: 4), cornerRadius: 1.5)
            missileA.position = CGPoint(x: 14, y: 23)
            missileA.fillColor = UIColor(red: 0.92, green: 0.92, blue: 0.84, alpha: 1.0)
            missileA.strokeColor = .clear
            missileA.zRotation = 0.34
            base.addChild(missileA)

            let missileB = SKShapeNode(rectOf: CGSize(width: 26, height: 4), cornerRadius: 1.5)
            missileB.position = CGPoint(x: 8, y: 15)
            missileB.fillColor = UIColor(red: 0.92, green: 0.92, blue: 0.84, alpha: 1.0)
            missileB.strokeColor = .clear
            missileB.zRotation = 0.34
            base.addChild(missileB)

            let stripe = SKShapeNode(rectOf: CGSize(width: 30, height: 5), cornerRadius: 1.5)
            stripe.position = CGPoint(x: -4, y: 1)
            stripe.fillColor = entity.faction.color
            stripe.strokeColor = .clear
            base.addChild(stripe)
        case .coastalBattery:
            let pad = SKShapeNode(rectOf: CGSize(width: 58, height: 32), cornerRadius: 4)
            pad.fillColor = UIColor(red: 0.40, green: 0.39, blue: 0.34, alpha: 1.0)
            pad.strokeColor = UIColor(white: 0.15, alpha: 1.0)
            pad.lineWidth = 2
            base.addChild(pad)

            let revetment = SKShapeNode(ellipseOf: CGSize(width: 54, height: 24))
            revetment.position = CGPoint(x: -2, y: 10)
            revetment.fillColor = UIColor(red: 0.28, green: 0.28, blue: 0.25, alpha: 1.0)
            revetment.strokeColor = UIColor(white: 0.12, alpha: 1.0)
            revetment.lineWidth = 1.5
            base.addChild(revetment)

            let turret = SKShapeNode(ellipseOf: CGSize(width: 32, height: 20))
            turret.position = CGPoint(x: -1, y: 18)
            turret.fillColor = UIColor(red: 0.48, green: 0.50, blue: 0.45, alpha: 1.0)
            turret.strokeColor = UIColor(white: 0.12, alpha: 1.0)
            turret.lineWidth = 1.5
            base.addChild(turret)

            let barrel = SKShapeNode(rectOf: CGSize(width: 42, height: 6), cornerRadius: 2)
            barrel.position = CGPoint(x: 29, y: 21)
            barrel.fillColor = UIColor(white: 0.10, alpha: 1.0)
            barrel.strokeColor = .clear
            base.addChild(barrel)

            let rangeMark = SKShapeNode(rectOf: CGSize(width: 28, height: 5), cornerRadius: 1.5)
            rangeMark.position = CGPoint(x: -3, y: 2)
            rangeMark.fillColor = entity.faction.color
            rangeMark.strokeColor = .clear
            base.addChild(rangeMark)
        default:
            break
        }
    }

    private func addLandUnitBody(for entity: GameEntity, to base: SKNode) {
        let fill = entity.faction == .enemy
            ? UIColor(red: 0.66, green: 0.48, blue: 0.28, alpha: 1.0)
            : UIColor(red: 0.72, green: 0.59, blue: 0.33, alpha: 1.0)

        switch entity.kind {
        case .aaTruck:
            let body = SKShapeNode(rectOf: CGSize(width: 38, height: 21), cornerRadius: 5)
            body.fillColor = fill
            body.strokeColor = UIColor(white: 0.18, alpha: 1.0)
            body.lineWidth = 2
            base.addChild(body)

            let cabin = SKShapeNode(rectOf: CGSize(width: 14, height: 12), cornerRadius: 3)
            cabin.position = CGPoint(x: -10, y: 6)
            cabin.fillColor = fill.darker(by: 0.12)
            cabin.strokeColor = .clear
            base.addChild(cabin)

            let launcher = SKShapeNode(rectOf: CGSize(width: 26, height: 7), cornerRadius: 2)
            launcher.position = CGPoint(x: 9, y: 11)
            launcher.fillColor = UIColor(red: 0.45, green: 0.48, blue: 0.43, alpha: 1.0)
            launcher.strokeColor = UIColor(white: 0.12, alpha: 1.0)
            launcher.lineWidth = 1
            launcher.zRotation = 0.24
            base.addChild(launcher)

            for offset in [-4, 4] {
                let missile = SKShapeNode(rectOf: CGSize(width: 22, height: 3), cornerRadius: 1)
                missile.position = CGPoint(x: 13, y: 13 + CGFloat(offset) * 0.45)
                missile.fillColor = UIColor(red: 0.90, green: 0.90, blue: 0.82, alpha: 1.0)
                missile.strokeColor = .clear
                missile.zRotation = 0.24
                base.addChild(missile)
            }

            for x in [-13, 13] {
                let wheel = SKShapeNode(ellipseOf: CGSize(width: 9, height: 5))
                wheel.position = CGPoint(x: CGFloat(x), y: -11)
                wheel.fillColor = UIColor(white: 0.08, alpha: 1.0)
                wheel.strokeColor = .clear
                base.addChild(wheel)
            }
        case .humvee:
            let body = SKShapeNode(rectOf: CGSize(width: 36, height: 20), cornerRadius: 5)
            body.fillColor = fill
            body.strokeColor = UIColor(white: 0.18, alpha: 1.0)
            body.lineWidth = 2
            base.addChild(body)

            let cabin = SKShapeNode(rectOf: CGSize(width: 16, height: 13), cornerRadius: 3)
            cabin.position = CGPoint(x: -2, y: 6)
            cabin.fillColor = fill.darker(by: 0.1)
            cabin.strokeColor = .clear
            base.addChild(cabin)

            let gun = SKShapeNode(rectOf: CGSize(width: 22, height: 4), cornerRadius: 2)
            gun.position = CGPoint(x: 16, y: 9)
            gun.fillColor = UIColor(white: 0.12, alpha: 1.0)
            gun.strokeColor = .clear
            base.addChild(gun)

            for x in [-13, 13] {
                let wheel = SKShapeNode(ellipseOf: CGSize(width: 9, height: 5))
                wheel.position = CGPoint(x: CGFloat(x), y: -11)
                wheel.fillColor = UIColor(white: 0.08, alpha: 1.0)
                wheel.strokeColor = .clear
                base.addChild(wheel)
            }
        case .tank:
            for yOffset in [-11, 11] {
                let track = SKShapeNode(rectOf: CGSize(width: 42, height: 7), cornerRadius: 3)
                track.position = CGPoint(x: -1, y: CGFloat(yOffset))
                track.fillColor = UIColor(white: 0.09, alpha: 1.0)
                track.strokeColor = UIColor(white: 0.22, alpha: 1.0)
                track.lineWidth = 1
                track.zPosition = -1
                base.addChild(track)

                for xOffset in [-13, 0, 13] {
                    let wheel = SKShapeNode(circleOfRadius: 2.4)
                    wheel.position = CGPoint(x: CGFloat(xOffset), y: CGFloat(yOffset))
                    wheel.fillColor = UIColor(white: 0.28, alpha: 1.0)
                    wheel.strokeColor = UIColor(white: 0.06, alpha: 1.0)
                    wheel.lineWidth = 0.8
                    wheel.zPosition = -0.5
                    base.addChild(wheel)
                }
            }

            let hull = SKShapeNode(rectOf: CGSize(width: 42, height: 25), cornerRadius: 5)
            hull.fillColor = fill
            hull.strokeColor = UIColor(white: 0.18, alpha: 1.0)
            hull.lineWidth = 2
            base.addChild(hull)

            let glacis = SKShapeNode(rectOf: CGSize(width: 10, height: 21), cornerRadius: 2)
            glacis.position = CGPoint(x: 16, y: 0)
            glacis.fillColor = fill.darker(by: -0.08)
            glacis.strokeColor = UIColor.white.withAlphaComponent(0.16)
            glacis.lineWidth = 1
            base.addChild(glacis)

            let turretRing = SKShapeNode(ellipseOf: CGSize(width: 27, height: 18))
            turretRing.position = CGPoint(x: -1, y: 2)
            turretRing.fillColor = fill.darker(by: 0.18)
            turretRing.strokeColor = UIColor(white: 0.12, alpha: 1.0)
            turretRing.lineWidth = 1.2
            base.addChild(turretRing)

            let turret = SKShapeNode(rectOf: CGSize(width: 22, height: 14), cornerRadius: 4)
            turret.fillColor = fill.darker(by: 0.12)
            turret.strokeColor = UIColor(white: 0.10, alpha: 0.9)
            turret.lineWidth = 1
            turret.position = CGPoint(x: 1, y: 3)
            base.addChild(turret)

            let mantlet = SKShapeNode(rectOf: CGSize(width: 7, height: 11), cornerRadius: 2)
            mantlet.position = CGPoint(x: 12, y: 4)
            mantlet.fillColor = fill.darker(by: 0.24)
            mantlet.strokeColor = .clear
            base.addChild(mantlet)

            let barrel = SKShapeNode(rectOf: CGSize(width: 28, height: 5), cornerRadius: 2)
            barrel.fillColor = UIColor(white: 0.18, alpha: 1.0)
            barrel.strokeColor = .clear
            barrel.position = CGPoint(x: 22, y: 4)
            base.addChild(barrel)

            let muzzleBrake = SKShapeNode(rectOf: CGSize(width: 7, height: 8), cornerRadius: 2)
            muzzleBrake.position = CGPoint(x: 37, y: 4)
            muzzleBrake.fillColor = UIColor(white: 0.12, alpha: 1.0)
            muzzleBrake.strokeColor = UIColor(white: 0.32, alpha: 1.0)
            muzzleBrake.lineWidth = 0.8
            base.addChild(muzzleBrake)

            let hatch = SKShapeNode(ellipseOf: CGSize(width: 8, height: 6))
            hatch.position = CGPoint(x: -4, y: 5)
            hatch.fillColor = fill.darker(by: -0.12)
            hatch.strokeColor = UIColor(white: 0.10, alpha: 1.0)
            hatch.lineWidth = 0.8
            base.addChild(hatch)

            let optic = SKShapeNode(rectOf: CGSize(width: 5, height: 3), cornerRadius: 1)
            optic.position = CGPoint(x: 5, y: 7)
            optic.fillColor = entity.faction == .enemy
                ? UIColor(red: 1.0, green: 0.46, blue: 0.22, alpha: 0.95)
                : UIColor(red: 0.30, green: 0.90, blue: 1.0, alpha: 0.95)
            optic.strokeColor = UIColor.white.withAlphaComponent(0.55)
            optic.lineWidth = 0.6
            base.addChild(optic)
        case .artillery:
            let hull = SKShapeNode(rectOf: CGSize(width: 40, height: 22), cornerRadius: 4)
            hull.fillColor = fill
            hull.strokeColor = UIColor(white: 0.18, alpha: 1.0)
            hull.lineWidth = 2
            base.addChild(hull)

            let cannon = SKShapeNode(rectOf: CGSize(width: 46, height: 5), cornerRadius: 2)
            cannon.fillColor = UIColor(white: 0.13, alpha: 1.0)
            cannon.strokeColor = .clear
            cannon.position = CGPoint(x: 18, y: 8)
            cannon.zRotation = 0.15
            base.addChild(cannon)
        case .mechanic:
            let body = SKShapeNode(rectOf: CGSize(width: 30, height: 20), cornerRadius: 5)
            body.fillColor = UIColor(red: 0.80, green: 0.76, blue: 0.58, alpha: 1.0)
            body.strokeColor = UIColor(white: 0.18, alpha: 1.0)
            body.lineWidth = 2
            base.addChild(body)

            let wrench = SKShapeNode(rectOf: CGSize(width: 24, height: 4), cornerRadius: 2)
            wrench.fillColor = UIColor(red: 0.18, green: 0.78, blue: 0.88, alpha: 1.0)
            wrench.strokeColor = .clear
            wrench.zRotation = 0.65
            base.addChild(wrench)
        default:
            break
        }
    }

    private func addAirUnitBody(for entity: GameEntity, to base: SKNode) {
        base.position.y += 28
        let bodyColor = entity.faction == .enemy
            ? UIColor(red: 0.72, green: 0.28, blue: 0.22, alpha: 1.0)
            : UIColor(red: 0.78, green: 0.68, blue: 0.42, alpha: 1.0)
        let glassColor = entity.faction == .enemy
            ? UIColor(red: 1.0, green: 0.55, blue: 0.30, alpha: 0.92)
            : UIColor(red: 0.42, green: 0.88, blue: 1.0, alpha: 0.92)

        if entity.kind == .helicopter {
            let rotorDisc = SKShapeNode(ellipseOf: CGSize(width: 62, height: 19))
            rotorDisc.position = CGPoint(x: 0, y: 13)
            rotorDisc.fillColor = UIColor.clear
            rotorDisc.strokeColor = UIColor.white.withAlphaComponent(0.28)
            rotorDisc.lineWidth = 1.3
            rotorDisc.zPosition = 5
            base.addChild(rotorDisc)

            let skidOffsets: [CGFloat] = [-12, 12]
            for yOffset in skidOffsets {
                let skid = SKShapeNode(rectOf: CGSize(width: 28, height: 2.5), cornerRadius: 1)
                skid.position = CGPoint(x: 1, y: yOffset)
                skid.fillColor = UIColor(white: 0.12, alpha: 0.90)
                skid.strokeColor = .clear
                skid.zPosition = -1
                base.addChild(skid)
            }

            let skidStrutOffsets: [CGFloat] = [-9, 10]
            for xOffset in skidStrutOffsets {
                for yOffset in skidOffsets {
                    let strut = SKShapeNode(rectOf: CGSize(width: 2.5, height: 8), cornerRadius: 1)
                    strut.position = CGPoint(x: xOffset, y: yOffset * 0.68)
                    strut.zRotation = xOffset < 0 ? -0.25 : 0.25
                    strut.fillColor = UIColor(white: 0.16, alpha: 0.92)
                    strut.strokeColor = .clear
                    strut.zPosition = -0.5
                    base.addChild(strut)
                }
            }

            let body = SKShapeNode(ellipseOf: CGSize(width: 34, height: 17))
            body.fillColor = bodyColor
            body.strokeColor = UIColor(white: 0.18, alpha: 1.0)
            body.lineWidth = 2
            base.addChild(body)

            let cockpit = SKShapeNode(ellipseOf: CGSize(width: 15, height: 10))
            cockpit.position = CGPoint(x: 10, y: 1)
            cockpit.fillColor = glassColor
            cockpit.strokeColor = UIColor.white.withAlphaComponent(0.62)
            cockpit.lineWidth = 1.2
            cockpit.zPosition = 2
            base.addChild(cockpit)

            let weaponPodOffsets: [CGFloat] = [-10, 10]
            for yOffset in weaponPodOffsets {
                let pod = SKShapeNode(rectOf: CGSize(width: 18, height: 5), cornerRadius: 2)
                pod.position = CGPoint(x: 0, y: yOffset)
                pod.fillColor = bodyColor.darker(by: 0.18)
                pod.strokeColor = UIColor(white: 0.12, alpha: 0.9)
                pod.lineWidth = 1
                pod.zPosition = 1
                base.addChild(pod)
            }

            let tail = SKShapeNode(rectOf: CGSize(width: 28, height: 5), cornerRadius: 2)
            tail.fillColor = bodyColor.darker(by: 0.1)
            tail.strokeColor = .clear
            tail.position = CGPoint(x: -25, y: 1)
            base.addChild(tail)

            let tailRotorNode = SKNode()
            tailRotorNode.position = CGPoint(x: -41, y: 1)
            tailRotorNode.zPosition = 3
            for angle in [CGFloat.zero, .pi / 2] {
                let blade = SKShapeNode(rectOf: CGSize(width: 15, height: 2.2), cornerRadius: 1)
                blade.zRotation = angle
                blade.fillColor = UIColor(white: 0.10, alpha: 0.88)
                blade.strokeColor = .clear
                tailRotorNode.addChild(blade)
            }
            let tailHub = SKShapeNode(circleOfRadius: 2.4)
            tailHub.fillColor = glassColor
            tailHub.strokeColor = UIColor(white: 0.12, alpha: 1.0)
            tailHub.lineWidth = 1
            tailRotorNode.addChild(tailHub)
            base.addChild(tailRotorNode)
            tailRotorNode.run(.repeatForever(.rotate(byAngle: .pi, duration: 0.22)))

            let rotor = SKShapeNode(rectOf: CGSize(width: 58, height: 3), cornerRadius: 1)
            rotor.fillColor = UIColor(white: 0.10, alpha: 0.85)
            rotor.strokeColor = .clear
            rotor.position = CGPoint(x: 0, y: 14)
            rotor.zPosition = 6
            base.addChild(rotor)
            rotor.run(.repeatForever(.sequence([.rotate(byAngle: .pi, duration: 0.18), .rotate(byAngle: .pi, duration: 0.18)])))

            let rotorHub = SKShapeNode(circleOfRadius: 4)
            rotorHub.position = CGPoint(x: 0, y: 14)
            rotorHub.fillColor = bodyColor.darker(by: 0.22)
            rotorHub.strokeColor = UIColor.white.withAlphaComponent(0.72)
            rotorHub.lineWidth = 1.2
            rotorHub.zPosition = 7
            base.addChild(rotorHub)
        } else {
            let jet = SKShapeNode(path: jetPath())
            jet.fillColor = bodyColor
            jet.strokeColor = UIColor(white: 0.16, alpha: 1.0)
            jet.lineWidth = 2
            base.addChild(jet)

            let spine = SKShapeNode(rectOf: CGSize(width: 34, height: 3.5), cornerRadius: 1.5)
            spine.position = CGPoint(x: 1, y: 0)
            spine.fillColor = bodyColor.darker(by: 0.18)
            spine.strokeColor = .clear
            spine.zPosition = 1
            base.addChild(spine)

            let canopy = SKShapeNode(ellipseOf: CGSize(width: 15, height: 8))
            canopy.position = CGPoint(x: 8, y: 0)
            canopy.fillColor = glassColor
            canopy.strokeColor = UIColor.white.withAlphaComponent(0.70)
            canopy.lineWidth = 1.2
            canopy.zPosition = 3
            base.addChild(canopy)

            let hardpointOffsets: [CGFloat] = [-13, 13]
            for yOffset in hardpointOffsets {
                let missile = SKShapeNode(rectOf: CGSize(width: 22, height: 3.5), cornerRadius: 1.5)
                missile.position = CGPoint(x: -1, y: yOffset)
                missile.fillColor = UIColor(white: 0.90, alpha: 1.0)
                missile.strokeColor = bodyColor.darker(by: 0.28)
                missile.lineWidth = 1
                missile.zPosition = 2
                base.addChild(missile)

                let pylon = SKShapeNode(rectOf: CGSize(width: 4, height: 7), cornerRadius: 1)
                pylon.position = CGPoint(x: -4, y: yOffset * 0.72)
                pylon.fillColor = bodyColor.darker(by: 0.14)
                pylon.strokeColor = .clear
                pylon.zPosition = 1.5
                base.addChild(pylon)
            }

            let stabilizerOffsets: [CGFloat] = [-7, 7]
            for yOffset in stabilizerOffsets {
                let stabilizer = SKShapeNode(rectOf: CGSize(width: 15, height: 3.5), cornerRadius: 1)
                stabilizer.position = CGPoint(x: -22, y: yOffset)
                stabilizer.zRotation = yOffset < 0 ? -0.28 : 0.28
                stabilizer.fillColor = bodyColor.darker(by: 0.12)
                stabilizer.strokeColor = .clear
                stabilizer.zPosition = 1
                base.addChild(stabilizer)
            }

            let noseSensor = SKShapeNode(circleOfRadius: 3)
            noseSensor.position = CGPoint(x: 24, y: 0)
            noseSensor.fillColor = glassColor
            noseSensor.strokeColor = UIColor.white.withAlphaComponent(0.75)
            noseSensor.lineWidth = 1
            noseSensor.zPosition = 4
            base.addChild(noseSensor)
        }
    }

    private func configureAirShadowNode(for entity: GameEntity) {
        guard entity.kind.domain == .air else { return }

        if entity.kind == .helicopter {
            let body = SKShapeNode(ellipseOf: CGSize(width: 31, height: 13))
            body.fillColor = UIColor.black.withAlphaComponent(0.30)
            body.strokeColor = .clear
            entity.airShadowNode.addChild(body)

            let tail = SKShapeNode(rectOf: CGSize(width: 24, height: 4), cornerRadius: 1)
            tail.position = CGPoint(x: -22, y: 0)
            tail.fillColor = UIColor.black.withAlphaComponent(0.26)
            tail.strokeColor = .clear
            entity.airShadowNode.addChild(tail)

            let rotor = SKShapeNode(rectOf: CGSize(width: 46, height: 2.5), cornerRadius: 1)
            rotor.position = CGPoint(x: 0, y: 7)
            rotor.fillColor = UIColor.black.withAlphaComponent(0.20)
            rotor.strokeColor = .clear
            entity.airShadowNode.addChild(rotor)
        } else {
            let jet = SKShapeNode(path: jetPath())
            jet.setScale(0.78)
            jet.fillColor = UIColor.black.withAlphaComponent(0.30)
            jet.strokeColor = .clear
            entity.airShadowNode.addChild(jet)
        }

        entity.airShadowNode.position = CGPoint(x: -10, y: -12)
        entity.airShadowNode.zPosition = -3
        entity.node.addChild(entity.airShadowNode)
    }

    private func addNavalUnitBody(for entity: GameEntity, to base: SKNode) {
        let navalColor = entity.faction == .enemy
            ? UIColor(red: 0.46, green: 0.34, blue: 0.32, alpha: 1.0)
            : UIColor(red: 0.31, green: 0.44, blue: 0.50, alpha: 1.0)

        switch entity.kind {
        case .battleship:
            let hull = SKShapeNode(path: shipHullPath(width: 74, height: 24))
            hull.fillColor = navalColor
            hull.strokeColor = UIColor(white: 0.12, alpha: 1.0)
            hull.lineWidth = 2
            base.addChild(hull)

            for x in [-18, 10] {
                let turret = SKShapeNode(rectOf: CGSize(width: 18, height: 12), cornerRadius: 2)
                turret.position = CGPoint(x: CGFloat(x), y: 5)
                turret.fillColor = UIColor(white: 0.76, alpha: 1.0)
                turret.strokeColor = .clear
                base.addChild(turret)
            }
        case .submarine:
            let hull = SKShapeNode(ellipseOf: CGSize(width: 58, height: 18))
            hull.fillColor = navalColor.darker(by: 0.15)
            hull.strokeColor = UIColor(white: 0.10, alpha: 1.0)
            hull.lineWidth = 2
            base.addChild(hull)

            let tower = SKShapeNode(rectOf: CGSize(width: 12, height: 14), cornerRadius: 2)
            tower.position = CGPoint(x: 0, y: 8)
            tower.fillColor = navalColor
            tower.strokeColor = .clear
            base.addChild(tower)
        case .carrier:
            let hull = SKShapeNode(path: shipHullPath(width: 92, height: 32))
            hull.fillColor = navalColor
            hull.strokeColor = UIColor(white: 0.10, alpha: 1.0)
            hull.lineWidth = 2
            base.addChild(hull)

            let deck = SKShapeNode(rectOf: CGSize(width: 72, height: 18), cornerRadius: 2)
            deck.fillColor = UIColor(white: 0.22, alpha: 1.0)
            deck.strokeColor = .clear
            base.addChild(deck)

            let stripe = SKShapeNode(rectOf: CGSize(width: 55, height: 2), cornerRadius: 1)
            stripe.fillColor = UIColor.white.withAlphaComponent(0.75)
            stripe.strokeColor = .clear
            stripe.zRotation = 0.18
            base.addChild(stripe)
        default:
            break
        }
    }

    private func configureNavalWakeNode(for entity: GameEntity) {
        guard entity.kind.domain == .naval else { return }

        let wakeLength: CGFloat = entity.kind == .carrier ? 78 : (entity.kind == .battleship ? 64 : 50)
        let wakeSpread: CGFloat = entity.kind == .carrier ? 22 : (entity.kind == .battleship ? 18 : 13)
        let startX = entity.kind.footprint * 0.24

        let washPath = CGMutablePath()
        washPath.move(to: CGPoint(x: startX, y: -4))
        washPath.addLine(to: CGPoint(x: wakeLength, y: -wakeSpread))
        washPath.move(to: CGPoint(x: startX, y: 4))
        washPath.addLine(to: CGPoint(x: wakeLength, y: wakeSpread))
        let wash = SKShapeNode(path: washPath)
        wash.strokeColor = UIColor(red: 0.48, green: 0.94, blue: 1.0, alpha: entity.kind == .submarine ? 0.16 : 0.24)
        wash.lineWidth = entity.kind == .carrier ? 11 : 8
        wash.lineCap = .round
        entity.navalWakeNode.addChild(wash)

        let foam = SKShapeNode(path: washPath)
        foam.strokeColor = UIColor(white: 0.96, alpha: entity.kind == .submarine ? 0.34 : 0.72)
        foam.lineWidth = entity.kind == .carrier ? 2.8 : 2.2
        foam.lineCap = .round
        entity.navalWakeNode.addChild(foam)

        for index in 0..<3 {
            let churn = SKShapeNode(ellipseOf: CGSize(width: 10 - CGFloat(index) * 1.6, height: 4.5 - CGFloat(index) * 0.6))
            churn.position = CGPoint(x: startX + 12 + CGFloat(index) * 13, y: 0)
            churn.fillColor = UIColor(white: 0.98, alpha: entity.kind == .submarine ? 0.22 : 0.58 - CGFloat(index) * 0.10)
            churn.strokeColor = .clear
            entity.navalWakeNode.addChild(churn)
        }

        entity.navalWakeNode.zPosition = -3
        entity.navalWakeNode.isHidden = true
        entity.node.addChild(entity.navalWakeNode)
    }

    private func layoutHUD() {
        hudNode.removeAllChildren()
        hudButtonFrames.removeAll()
        hudButtonSubtitleLabels.removeAll()
        hudButtonShapes.removeAll()
        hudPageFrames.removeAll()
        hudPageShapes.removeAll()
        selectionInfoRowLabels.removeAll()

        let halfW = size.width / 2
        let halfH = size.height / 2

        let topPanel = SKShapeNode(rectOf: CGSize(width: 276, height: 62), cornerRadius: 7)
        topPanel.fillColor = UIColor(red: 0.14, green: 0.13, blue: 0.10, alpha: 0.92)
        topPanel.strokeColor = UIColor(red: 0.86, green: 0.68, blue: 0.28, alpha: 1.0)
        topPanel.lineWidth = 3
        topPanel.position = CGPoint(x: -halfW + 156, y: halfH - 54)
        hudNode.addChild(topPanel)

        let coin = SKShapeNode(ellipseOf: CGSize(width: 36, height: 36))
        coin.fillColor = UIColor(red: 0.96, green: 0.82, blue: 0.18, alpha: 1.0)
        coin.strokeColor = UIColor(red: 0.45, green: 0.34, blue: 0.05, alpha: 1.0)
        coin.lineWidth = 3
        coin.position = CGPoint(x: -halfW + 47, y: halfH - 54)
        hudNode.addChild(coin)

        moneyLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        moneyLabel.fontSize = 30
        moneyLabel.fontColor = UIColor(red: 0.86, green: 0.89, blue: 0.83, alpha: 1.0)
        moneyLabel.horizontalAlignmentMode = .left
        moneyLabel.verticalAlignmentMode = .center
        moneyLabel.position = CGPoint(x: -halfW + 76, y: halfH - 48)
        hudNode.addChild(moneyLabel)

        incomeLabel = SKLabelNode(fontNamed: "Menlo")
        incomeLabel.fontSize = 12
        incomeLabel.fontColor = UIColor(red: 0.74, green: 0.88, blue: 0.63, alpha: 1.0)
        incomeLabel.horizontalAlignmentMode = .left
        incomeLabel.verticalAlignmentMode = .center
        incomeLabel.position = CGPoint(x: -halfW + 79, y: halfH - 75)
        hudNode.addChild(incomeLabel)

        let actions = hudPage.actions
        let pages = HudPage.allCases
        let compactHUD = size.width < 1180
        let minimumCommandButtonWidth: CGFloat = compactHUD ? 40 : 48
        let commandButtonHeight: CGFloat = compactHUD ? 54 : 68
        let commandBarHeight = commandButtonHeight
        let commandBarTop = -halfH + 18 + commandBarHeight

        selectedLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        selectedLabel.fontSize = compactHUD ? 12 : 14
        selectedLabel.fontColor = .white
        selectedLabel.horizontalAlignmentMode = .left
        selectedLabel.verticalAlignmentMode = .center
        selectedLabel.position = CGPoint(x: -halfW + 28, y: commandBarTop + 34)
        hudNode.addChild(selectedLabel)

        queueLabel = SKLabelNode(fontNamed: "Menlo")
        queueLabel.fontSize = compactHUD ? 10 : 12
        queueLabel.fontColor = UIColor(red: 0.95, green: 0.82, blue: 0.46, alpha: 1.0)
        queueLabel.horizontalAlignmentMode = .left
        queueLabel.verticalAlignmentMode = .center
        queueLabel.position = CGPoint(x: -halfW + 28, y: commandBarTop + 14)
        hudNode.addChild(queueLabel)

        messageLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        messageLabel.fontSize = 15
        messageLabel.fontColor = .white
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.verticalAlignmentMode = .center
        messageLabel.position = CGPoint(x: 0, y: halfH - 52)
        hudNode.addChild(messageLabel)

        let missionPanelWidth = min(compactHUD ? 350 : 500, max(280, size.width - 590))
        let missionPanelHeight: CGFloat = compactHUD ? 52 : 58
        let missionPanelY = halfH - (compactHUD ? 102 : 106)
        let missionPanel = SKShapeNode(rectOf: CGSize(width: missionPanelWidth, height: missionPanelHeight), cornerRadius: 7)
        missionPanel.fillColor = UIColor(red: 0.07, green: 0.08, blue: 0.08, alpha: 0.88)
        missionPanel.strokeColor = UIColor(red: 0.70, green: 0.58, blue: 0.28, alpha: 0.92)
        missionPanel.lineWidth = 2.5
        missionPanel.position = CGPoint(x: 0, y: missionPanelY)
        hudNode.addChild(missionPanel)

        missionTitleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        missionTitleLabel.fontSize = compactHUD ? 11 : 13
        missionTitleLabel.fontColor = UIColor(red: 0.98, green: 0.84, blue: 0.46, alpha: 1.0)
        missionTitleLabel.horizontalAlignmentMode = .left
        missionTitleLabel.verticalAlignmentMode = .center
        missionTitleLabel.position = CGPoint(x: -missionPanelWidth / 2 + 14, y: missionPanelY + 12)
        hudNode.addChild(missionTitleLabel)

        missionDetailLabel = SKLabelNode(fontNamed: "Menlo")
        missionDetailLabel.fontSize = compactHUD ? 9 : 11
        missionDetailLabel.fontColor = UIColor(white: 0.92, alpha: 1.0)
        missionDetailLabel.horizontalAlignmentMode = .left
        missionDetailLabel.verticalAlignmentMode = .center
        missionDetailLabel.position = CGPoint(x: -missionPanelWidth / 2 + 14, y: missionPanelY - 12)
        hudNode.addChild(missionDetailLabel)

        let statusPanelY = min(commandBarTop + 80, halfH - 122)
        let statusPanel = SKShapeNode(rectOf: CGSize(width: 244, height: 56), cornerRadius: 7)
        statusPanel.fillColor = UIColor(red: 0.10, green: 0.12, blue: 0.12, alpha: 0.88)
        statusPanel.strokeColor = UIColor(white: 0.08, alpha: 1.0)
        statusPanel.lineWidth = 3
        statusPanel.position = CGPoint(x: -halfW + 150, y: statusPanelY)
        hudNode.addChild(statusPanel)

        forcesLabel = SKLabelNode(fontNamed: "Menlo")
        forcesLabel.fontSize = 12
        forcesLabel.fontColor = UIColor(red: 0.72, green: 0.90, blue: 1.0, alpha: 1.0)
        forcesLabel.horizontalAlignmentMode = .left
        forcesLabel.verticalAlignmentMode = .center
        forcesLabel.position = CGPoint(x: -halfW + 38, y: statusPanelY + 8)
        hudNode.addChild(forcesLabel)

        aiStatusLabel = SKLabelNode(fontNamed: "Menlo")
        aiStatusLabel.fontSize = 12
        aiStatusLabel.fontColor = UIColor(red: 1.0, green: 0.72, blue: 0.62, alpha: 1.0)
        aiStatusLabel.horizontalAlignmentMode = .left
        aiStatusLabel.verticalAlignmentMode = .center
        aiStatusLabel.position = CGPoint(x: -halfW + 38, y: statusPanelY - 12)
        hudNode.addChild(aiStatusLabel)

        minimapFrame = CGRect(x: halfW - 238, y: halfH - 208, width: 210, height: 158)
        addMinimap(frame: minimapFrame)

        let infoPanelTop = minimapFrame.minY - 12
        let infoPanelBottomLimit = commandBarTop + (compactHUD ? 72 : 38)
        let infoPanelHeight = max(104, min(compactHUD ? 124 : 152, infoPanelTop - infoPanelBottomLimit))
        let infoPanelFrame = CGRect(
            x: minimapFrame.minX,
            y: infoPanelTop - infoPanelHeight,
            width: minimapFrame.width,
            height: infoPanelHeight
        )
        addSelectionInfoPanel(frame: infoPanelFrame, compact: compactHUD)

        let gap: CGFloat = compactHUD ? 5 : 7
        let availableWidth = size.width - 32
        let pageButtonWidth: CGFloat = compactHUD ? 44 : 64
        let elementCount = pages.count + actions.count
        let gapWidth = CGFloat(max(0, elementCount - 1)) * gap
        let actionWidth = min(
            compactHUD ? 76 : 86,
            (availableWidth - CGFloat(pages.count) * pageButtonWidth - gapWidth) / CGFloat(actions.count)
        )
        let buttonSize = CGSize(width: max(minimumCommandButtonWidth, actionWidth), height: commandButtonHeight)
        let totalWidth = CGFloat(pages.count) * pageButtonWidth + CGFloat(actions.count) * buttonSize.width + gapWidth
        var x = -totalWidth / 2
        let y = -halfH + 18 + commandButtonHeight / 2

        for page in pages {
            let frame = CGRect(x: x, y: y - commandButtonHeight / 2, width: pageButtonWidth, height: commandButtonHeight)
            hudPageFrames[page] = frame
            hudNode.addChild(makeHudPageTab(page: page, frame: frame))
            x += pageButtonWidth + gap
        }
        for action in actions {
            let frame = CGRect(x: x, y: y - commandButtonHeight / 2, width: buttonSize.width, height: commandButtonHeight)
            hudButtonFrames[action] = frame
            hudNode.addChild(makeButton(action: action, frame: frame))
            x += buttonSize.width + gap
        }

        refreshHudButtonStyles()
    }

    private func addMinimap(frame: CGRect) {
        let panel = SKShapeNode(rect: frame, cornerRadius: 7)
        panel.fillColor = UIColor(red: 0.04, green: 0.06, blue: 0.06, alpha: 0.92)
        panel.strokeColor = UIColor(red: 0.78, green: 0.68, blue: 0.42, alpha: 1.0)
        panel.lineWidth = 3
        hudNode.addChild(panel)

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.text = "TACTICAL MAP"
        title.fontSize = 11
        title.fontColor = UIColor(red: 0.95, green: 0.84, blue: 0.55, alpha: 1.0)
        title.horizontalAlignmentMode = .left
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: frame.minX + 10, y: frame.maxY - 13)
        hudNode.addChild(title)

        for row in 0..<rows {
            for col in 0..<cols {
                let tile = TileCoord(row: row, col: col)
                let point = minimapPoint(forWorldPoint: tileCenter(tile))
                let dot = SKShapeNode(rectOf: CGSize(width: 5, height: 4), cornerRadius: 0.6)
                dot.position = point
                dot.fillColor = minimapTerrainColor(terrain[row][col])
                dot.strokeColor = .clear
                dot.alpha = terrain[row][col] == .water ? 0.85 : 0.68
                hudNode.addChild(dot)
            }
        }

        minimapBlipsNode = SKNode()
        hudNode.addChild(minimapBlipsNode)

        minimapCameraBox = SKShapeNode(rectOf: CGSize(width: 40, height: 28), cornerRadius: 2)
        minimapCameraBox.strokeColor = UIColor.white
        minimapCameraBox.fillColor = UIColor.clear
        minimapCameraBox.lineWidth = 2
        hudNode.addChild(minimapCameraBox)
    }

    private func addSelectionInfoPanel(frame: CGRect, compact: Bool) {
        let panel = SKShapeNode(rect: frame, cornerRadius: 7)
        panel.fillColor = UIColor(red: 0.05, green: 0.07, blue: 0.07, alpha: 0.90)
        panel.strokeColor = UIColor(red: 0.34, green: 0.64, blue: 0.70, alpha: 0.95)
        panel.lineWidth = 2.5
        hudNode.addChild(panel)

        selectionInfoTitleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        selectionInfoTitleLabel.fontSize = compact ? 10 : 11
        selectionInfoTitleLabel.fontColor = UIColor(red: 0.74, green: 0.95, blue: 1.0, alpha: 1.0)
        selectionInfoTitleLabel.horizontalAlignmentMode = .left
        selectionInfoTitleLabel.verticalAlignmentMode = .center
        selectionInfoTitleLabel.position = CGPoint(x: frame.minX + 10, y: frame.maxY - 14)
        hudNode.addChild(selectionInfoTitleLabel)

        let rowCount = compact ? 4 : 5
        let rowGap: CGFloat = compact ? 18 : 20
        for index in 0..<rowCount {
            let row = SKLabelNode(fontNamed: "Menlo")
            row.fontSize = compact ? 9 : 10
            row.fontColor = UIColor(white: 0.90, alpha: 1.0)
            row.horizontalAlignmentMode = .left
            row.verticalAlignmentMode = .center
            row.position = CGPoint(x: frame.minX + 10, y: frame.maxY - 36 - CGFloat(index) * rowGap)
            hudNode.addChild(row)
            selectionInfoRowLabels.append(row)
        }
    }

    private func minimapTerrainColor(_ terrain: Terrain) -> UIColor {
        switch terrain {
        case .sand:
            return UIColor(red: 0.73, green: 0.61, blue: 0.36, alpha: 1.0)
        case .road:
            return UIColor(red: 0.46, green: 0.45, blue: 0.39, alpha: 1.0)
        case .water:
            return UIColor(red: 0.05, green: 0.46, blue: 0.58, alpha: 1.0)
        case .oil:
            return UIColor(red: 0.12, green: 0.10, blue: 0.08, alpha: 1.0)
        case .ridge:
            return UIColor(red: 0.28, green: 0.25, blue: 0.22, alpha: 1.0)
        }
    }

    private func makeButton(action: HudAction, frame: CGRect) -> SKNode {
        let node = SKNode()
        node.name = "hud:\(action.rawValue)"
        node.position = CGPoint(x: frame.midX, y: frame.midY)

        let shape = SKShapeNode(rectOf: frame.size, cornerRadius: 8)
        shape.fillColor = buttonColor(for: action)
        shape.strokeColor = UIColor.black
        shape.lineWidth = 4
        node.addChild(shape)
        hudButtonShapes[action] = shape

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.text = action.title
        title.fontSize = frame.width < 48 ? 10 : (frame.width < 62 ? 13 : 16)
        title.fontColor = .white
        title.verticalAlignmentMode = .center
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: frame.height < 62 ? 9 : 12)
        node.addChild(title)

        let subtitleLabel = SKLabelNode(fontNamed: "Menlo")
        subtitleLabel.text = subtitle(for: action)
        subtitleLabel.fontSize = frame.width < 48 ? 6 : (frame.width < 62 ? 7 : 9)
        subtitleLabel.fontColor = UIColor(white: 0.92, alpha: 1.0)
        subtitleLabel.verticalAlignmentMode = .center
        subtitleLabel.horizontalAlignmentMode = .center
        subtitleLabel.position = CGPoint(x: 0, y: frame.height < 62 ? -14 : -18)
        node.addChild(subtitleLabel)
        hudButtonSubtitleLabels[action] = subtitleLabel

        return node
    }

    private func makeHudPageTab(page: HudPage, frame: CGRect) -> SKNode {
        let node = SKNode()
        node.name = "hud-page:\(page.rawValue)"
        node.position = CGPoint(x: frame.midX, y: frame.midY)

        let shape = SKShapeNode(rectOf: frame.size, cornerRadius: 7)
        shape.fillColor = hudPageColor(page, active: page == hudPage)
        shape.strokeColor = UIColor.black
        shape.lineWidth = 3
        node.addChild(shape)
        hudPageShapes[page] = shape

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.text = page.title
        title.fontSize = frame.width < 48 ? 9 : (frame.width < 60 ? 10 : 12)
        title.fontColor = .white
        title.verticalAlignmentMode = .center
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: 8)
        node.addChild(title)

        let subtitle = SKLabelNode(fontNamed: "Menlo")
        subtitle.text = page.subtitle
        subtitle.fontSize = frame.width < 48 ? 5.5 : (frame.width < 60 ? 6 : 7)
        subtitle.fontColor = UIColor(white: 0.88, alpha: 1.0)
        subtitle.verticalAlignmentMode = .center
        subtitle.horizontalAlignmentMode = .center
        subtitle.position = CGPoint(x: 0, y: -13)
        node.addChild(subtitle)
        return node
    }

    private func isHudActionArmed(_ action: HudAction) -> Bool {
        switch action {
        case .buildBase:
            return pendingConstructionKind != nil
        case .setRally:
            return isSettingRallyPoint
        case .attackMove:
            return isSettingAttackMove
        case .reconSweep, .fieldRepair, .airStrike, .navalBarrage:
            return action.supportPower != nil && action.supportPower == pendingSupportPower
        default:
            return false
        }
    }

    private func refreshHudButtonStyles() {
        for (action, shape) in hudButtonShapes {
            shape.fillColor = buttonColor(for: action)
            shape.alpha = 1.0

            if isHudActionArmed(action) {
                shape.strokeColor = UIColor(red: 1.0, green: 0.84, blue: 0.26, alpha: 1.0)
                shape.lineWidth = 5.5
                shape.glowWidth = 3
            } else {
                shape.strokeColor = UIColor.black
                shape.lineWidth = 4
                shape.glowWidth = 0
            }
        }
        refreshHudPageStyles()
    }

    private func refreshHudPageStyles() {
        for (page, shape) in hudPageShapes {
            let isActive = page == hudPage
            let containsArmedAction = page.actions.contains { isHudActionArmed($0) }
            shape.fillColor = hudPageColor(page, active: isActive)
            shape.strokeColor = isActive || containsArmedAction
                ? UIColor(red: 1.0, green: 0.82, blue: 0.28, alpha: 1.0)
                : UIColor.black
            shape.lineWidth = isActive ? 4 : (containsArmedAction ? 3.5 : 3)
            shape.glowWidth = containsArmedAction ? 2.5 : (isActive ? 1.2 : 0)
        }
    }

    private func hudPageColor(_ page: HudPage, active: Bool) -> UIColor {
        let alpha: CGFloat = active ? 0.98 : 0.82
        switch page {
        case .tactical:
            return UIColor(red: active ? 0.16 : 0.10, green: active ? 0.48 : 0.25, blue: active ? 0.32 : 0.22, alpha: alpha)
        case .build:
            return UIColor(red: active ? 0.58 : 0.27, green: active ? 0.43 : 0.27, blue: active ? 0.18 : 0.20, alpha: alpha)
        case .air:
            return UIColor(red: active ? 0.30 : 0.16, green: active ? 0.48 : 0.28, blue: active ? 0.66 : 0.36, alpha: alpha)
        case .naval:
            return UIColor(red: active ? 0.10 : 0.08, green: active ? 0.42 : 0.25, blue: active ? 0.56 : 0.32, alpha: alpha)
        case .support:
            return UIColor(red: active ? 0.40 : 0.20, green: active ? 0.36 : 0.25, blue: active ? 0.48 : 0.30, alpha: alpha)
        }
    }

    private func buttonColor(for action: HudAction) -> UIColor {
        switch action {
        case .selectArmy:
            UIColor(red: 0.10, green: 0.62, blue: 0.25, alpha: 0.96)
        case .controlGroup1, .controlGroup2:
            UIColor(red: 0.24, green: 0.43, blue: 0.40, alpha: 0.96)
        case .holdPosition:
            UIColor(red: 0.30, green: 0.48, blue: 0.22, alpha: 0.96)
        case .attackMove:
            UIColor(red: 0.62, green: 0.34, blue: 0.18, alpha: 0.96)
        case .buildHelicopter, .buildFighter:
            UIColor(red: 0.36, green: 0.52, blue: 0.66, alpha: 0.96)
        case .buildBattleship, .buildSubmarine, .buildCarrier:
            UIColor(red: 0.12, green: 0.45, blue: 0.58, alpha: 0.96)
        case .setRally:
            UIColor(red: 0.18, green: 0.48, blue: 0.52, alpha: 0.96)
        case .buildBase:
            UIColor(red: 0.60, green: 0.48, blue: 0.24, alpha: 0.96)
        case .reconSweep:
            UIColor(red: 0.16, green: 0.44, blue: 0.62, alpha: 0.96)
        case .fieldRepair:
            UIColor(red: 0.12, green: 0.56, blue: 0.46, alpha: 0.96)
        case .airStrike:
            UIColor(red: 0.42, green: 0.48, blue: 0.62, alpha: 0.96)
        case .navalBarrage:
            UIColor(red: 0.08, green: 0.34, blue: 0.46, alpha: 0.96)
        case .cycleAI:
            UIColor(red: 0.58, green: 0.24, blue: 0.18, alpha: 0.96)
        case .focusHQ:
            UIColor(red: 0.50, green: 0.42, blue: 0.28, alpha: 0.96)
        case .newSkirmish:
            UIColor(red: 0.22, green: 0.22, blue: 0.24, alpha: 0.96)
        default:
            UIColor(red: 0.62, green: 0.57, blue: 0.47, alpha: 0.96)
        }
    }

    private func subtitle(for action: HudAction) -> String {
        if let kind = action.buildKind {
            return productionButtonSubtitle(for: kind)
        }
        if let power = action.supportPower {
            return supportButtonSubtitle(for: power)
        }
        switch action {
        case .selectArmy:
            return "all combat"
        case .controlGroup1:
            return controlGroupSubtitle(for: 1)
        case .controlGroup2:
            return controlGroupSubtitle(for: 2)
        case .holdPosition:
            return holdButtonSubtitle()
        case .attackMove:
            return attackMoveButtonSubtitle()
        case .buildBase:
            let kind = pendingConstructionKind ?? nextStructureKind()
            return "$\(kind.cost) \(kind.shortCode)"
        case .setRally:
            return "point"
        case .cycleAI:
            return aiDifficulty.displayName
        case .focusHQ:
            return "center"
        case .newSkirmish:
            return "restart"
        default:
            return ""
        }
    }

    private func holdButtonSubtitle() -> String {
        let mobileUnits = selectedMobilePlayerUnits()
        if mobileUnits.contains(where: { $0.kind == .carrier }) {
            return "CV GW"
        }
        if mobileUnits.contains(where: { unit in
            (unit.kind == .helicopter || unit.kind == .fighter) &&
                carrierGuardAnchor(for: unit) != nil
        }) {
            return "CV rel"
        }
        return "guard"
    }

    private func attackMoveButtonSubtitle() -> String {
        let combatUnits = selectedMobilePlayerUnits().filter { $0.kind.damage > 0 }
        if combatUnits.contains(where: { unit in
            (unit.kind == .helicopter || unit.kind == .fighter) &&
                carrierGuardAnchor(for: unit) != nil
        }) {
            return "CV rel"
        }
        if combatUnits.contains(where: { unit in
            unit.kind == .carrier &&
                unit.holdPosition != nil &&
                !boundCarrierGuardWing(for: unit).isEmpty
        }) {
            return "CV rel"
        }
        return "push"
    }

    private func productionButtonSubtitle(for kind: EntityKind) -> String {
        switch kind {
        case .aaTruck, .humvee, .tank, .artillery, .mechanic:
            guard let source = productionSource(for: kind, faction: .player) else {
                return "need WF"
            }
            return "\(source.kind.shortCode) $\(kind.cost)"
        case .helicopter, .fighter:
            guard let source = productionSource(for: kind, faction: .player) else {
                return "need AF/CV"
            }
            return "\(source.kind.shortCode) $\(kind.cost)"
        case .battleship, .submarine, .carrier:
            guard let source = productionSource(for: kind, faction: .player) else {
                return "need SY"
            }
            return "\(source.kind.shortCode) $\(kind.cost)"
        default:
            return "$\(kind.cost)"
        }
    }

    private func supportButtonSubtitle(for power: SupportPower) -> String {
        let cooldown = supportCooldown(for: .player, power: power)
        if cooldown > 0 {
            return "\(Int(ceil(cooldown)))s"
        }
        if !hasOperationalSupportAsset(for: power, faction: .player) {
            return "need \(supportAssetRequirementLabel(for: power))"
        }
        let shortfall = power.cost - money(for: .player)
        if shortfall > 0 {
            return "need $\(shortfall)"
        }
        return "$\(power.cost)"
    }

    private func updateHUD() {
        let income = incomePerTick(for: .player)
        moneyLabel.text = "$\(playerMoney)"
        incomeLabel.text = "+$\(income)/sec  Oil \(oilCount(for: .player))  Flags \(controlPointCount(for: .player))"
        forcesLabel.text = "Blue \(mobileCount(for: .player)) units  Oil \(oilCount(for: .player))  Flags \(controlPointCount(for: .player))"
        let enemyStatus = currentEnemyAssaultWaveSummary() ?? "AI \(aiDifficulty.displayName)"
        aiStatusLabel.text = "R\(mobileCount(for: .enemy)) F\(controlPointCount(for: .enemy)) \(enemyStatus)"
        let missionStatus = missionStatusContent()
        missionTitleLabel.text = missionStatus.title
        missionDetailLabel.text = missionStatus.detail
        for (action, subtitleLabel) in hudButtonSubtitleLabels {
            subtitleLabel.text = subtitle(for: action)
            if let power = action.supportPower, supportCooldown(for: .player, power: power) > 0 {
                subtitleLabel.fontColor = UIColor(red: 1.0, green: 0.72, blue: 0.56, alpha: 1.0)
            } else {
                subtitleLabel.fontColor = UIColor(white: 0.92, alpha: 1.0)
            }
        }
        refreshHudButtonStyles()

        let selected = selectedIDs.compactMap { entities[$0] }.filter { $0.isAlive }
        refreshAirDefenseThreatVisuals(for: selected)
        refreshCommandIntentVisuals(for: selected)
        refreshFocusFireMarker(for: selected)
        if let pendingConstructionKind {
            selectedLabel.text = "Place \(pendingConstructionKind.displayName): tap valid ground."
        } else if isSettingRallyPoint {
            selectedLabel.text = "Set rally point: tap map for selected factory or carrier."
        } else if isSettingAttackMove {
            selectedLabel.text = "Attack move: tap map for selected combat units."
        } else if let pendingSupportPower {
            selectedLabel.text = "Target \(pendingSupportPower.displayName): tap map."
        } else if selected.isEmpty {
            selectedLabel.text = "Tap a unit, then tap ground or enemy to command."
        } else if selected.count == 1, let entity = selected.first {
            if entity.kind.isStructure && !entity.isOperational {
                selectedLabel.text = "\(entity.kind.displayName) building \(Int(ceil(entity.buildProgressRemaining)))s"
            } else if entity.kind.supportsRallyPoint, let rallyPoint = entity.rallyPoint, let tile = tile(at: rallyPoint) {
                selectedLabel.text = "\(entity.kind.displayName)  HP \(Int(entity.hp))/\(Int(entity.kind.maxHP))  Rally \(tile.row),\(tile.col)"
            } else {
                selectedLabel.text = "\(entity.kind.displayName)  HP \(Int(entity.hp))/\(Int(entity.kind.maxHP))"
            }
        } else {
            selectedLabel.text = "\(selected.count) units selected"
        }
        if let threatSummary = airDefenseThreatSummaryLine(for: selected) {
            selectedLabel.text = "\(selectedLabel.text ?? "")  |  \(threatSummary)"
        }

        let playerQueue = buildOrders.filter { $0.faction == .player }
        if playerQueue.isEmpty {
            queueLabel.text = "Queue: idle"
        } else {
            let summary = playerQueue.prefix(3).map { "\($0.kind.shortCode) \(Int(ceil($0.remaining)))s" }.joined(separator: "  ")
            queueLabel.text = "Queue: \(summary)"
        }

        updateSelectionInfoPanel(selected: selected)

        if let victoryState {
            messageLabel.text = victoryState
        }

        updateMinimap()
    }

    private func mobileCount(for faction: Faction) -> Int {
        entities.values.filter { $0.faction == faction && !$0.kind.isStructure && $0.isAlive }.count
    }

    private func missionStatusContent() -> (title: String, detail: String) {
        if let victoryState {
            if victoryState.hasPrefix("Victory") {
                return ("MISSION COMPLETE", "Red Command HQ destroyed. Battlefield secured.")
            }
            return ("MISSION FAILED", "Command HQ lost. Restart the skirmish to try again.")
        }

        guard let stage = activeMissionStage() else {
            return ("OBJECTIVES COMPLETE", "All mission stages complete. Hold the field.")
        }

        return (
            "OBJ \(stage.rawValue + 1)/\(MissionStage.allCases.count) - \(stage.title)",
            missionDetail(for: stage)
        )
    }

    private func missionDetail(for stage: MissionStage) -> String {
        switch stage {
        case .secureOil:
            return "Hold 2 oil derricks. \(min(oilCount(for: .player), 2))/2 secured."
        case .captureFrontline:
            return "Hold 2 front-line flags. \(min(controlPointCount(for: .player), 2))/2 secured."
        case .secureCoast:
            let assets = coastalAssetBreakdown(for: .player)
            let total = assets.shipyards + assets.sonarBuoys + assets.coastalBatteries
            return "Hold 2 coastal assets. \(min(total, 2))/2 secured. SY\(assets.shipyards) SON\(assets.sonarBuoys) CB\(assets.coastalBatteries) +$600"
        case .combinedArms:
            let counts = playerMobileDomainCounts()
            return "Field 10 units: \(min(counts.total, 10))/10  L\(counts.land) A\(counts.air) N\(counts.naval)  +$800"
        case .breakRedProduction:
            let remaining = enemyProductionCount()
            return remaining == 0 ? "Red production disabled. Push to the HQ. +$900" : "Destroy Red WF/AF/SY/CV. \(remaining) left. +$900"
        case .destroyHQ:
            guard enemyHQ() != nil else {
                return "Red Command HQ destroyed."
            }
            guard let redHQ = playerKnownEnemyHQ() else {
                return "Locate Red HQ with scouts or SCAN, then finish it."
            }
            return "Red HQ HP \(Int(redHQ.hp))/\(Int(redHQ.kind.maxHP)). Finish the assault."
        }
    }

    private func activeMissionStage() -> MissionStage? {
        MissionStage.allCases.first { !completedMissionStages.contains($0) }
    }

    private func updateMissionProgress() {
        guard victoryState == nil else { return }

        var completedStage: MissionStage?
        var completedReward = 0
        while let stage = activeMissionStage(), isMissionStageComplete(stage) {
            completedMissionStages.insert(stage)
            completedStage = stage
            let reward = missionReward(for: stage)
            if reward > 0 {
                changeMoney(for: .player, by: reward)
                completedReward += reward
            }
        }

        if let completedStage {
            let rewardText = completedReward > 0 ? " +$\(completedReward)" : ""
            showMessage("Objective complete: \(completedStage.title)\(rewardText)", color: UIColor(red: 0.76, green: 1.0, blue: 0.58, alpha: 1.0))
        }
    }

    private func missionReward(for stage: MissionStage) -> Int {
        switch stage {
        case .secureCoast:
            return 600
        case .combinedArms:
            return 800
        case .breakRedProduction:
            return 900
        default:
            return 0
        }
    }

    private func isMissionStageComplete(_ stage: MissionStage) -> Bool {
        switch stage {
        case .secureOil:
            return oilCount(for: .player) >= 2
        case .captureFrontline:
            return controlPointCount(for: .player) >= 2
        case .secureCoast:
            return coastalAssetCount(for: .player) >= 2
        case .combinedArms:
            let counts = playerMobileDomainCounts()
            return counts.total >= 10 && counts.land > 0 && counts.air > 0 && counts.naval > 0
        case .breakRedProduction:
            return enemyProductionCount() == 0
        case .destroyHQ:
            return !entities.values.contains { $0.kind == .hq && $0.faction == .enemy && $0.isAlive }
        }
    }

    private func enemyHQ() -> GameEntity? {
        entities.values.first { $0.kind == .hq && $0.faction == .enemy && $0.isAlive }
    }

    private func playerKnownEnemyHQ() -> GameEntity? {
        guard let redHQ = enemyHQ(), isKnownToFaction(redHQ, observer: .player) else { return nil }
        return redHQ
    }

    private func playerMobileDomainCounts() -> (land: Int, air: Int, naval: Int, total: Int) {
        let units = entities.values.filter { $0.faction == .player && !$0.kind.isStructure && $0.isAlive }
        let land = units.filter { $0.kind.domain == .land }.count
        let air = units.filter { $0.kind.domain == .air }.count
        let naval = units.filter { $0.kind.domain == .naval }.count
        return (land, air, naval, units.count)
    }

    private func enemyProductionCount() -> Int {
        entities.values.filter { entity in
            entity.faction == .enemy &&
            entity.isAlive &&
            (entity.kind == .barracks || entity.kind == .airfield || entity.kind == .shipyard || entity.kind == .carrier)
        }.count
    }

    private func updateSelectionInfoPanel(selected: [GameEntity]) {
        let content = selectionInfoContent(for: selected)
        selectionInfoTitleLabel.text = content.title
        for (index, label) in selectionInfoRowLabels.enumerated() {
            label.text = index < content.rows.count ? content.rows[index] : ""
        }
    }

    private func selectionInfoContent(for selected: [GameEntity]) -> (title: String, rows: [String]) {
        if let pendingConstructionKind {
            return (
                "BUILD \(pendingConstructionKind.shortCode)",
                [
                    "$\(pendingConstructionKind.cost)  HP \(Int(pendingConstructionKind.maxHP))",
                    "Build \(Int(pendingConstructionKind.buildTime))s  \(domainLabel(for: pendingConstructionKind.domain))",
                    pendingConstructionKind == .shipyard || pendingConstructionKind == .sonarBuoy || pendingConstructionKind == .coastalBattery ? "Needs coast tile" : "Needs base/flag coverage",
                    pendingConstructionKind == .oilDerrick ? "Requires oil field" : "Requires visible ground"
                ]
            )
        }

        if let pendingSupportPower {
            let cooldown = supportCooldown(for: .player, power: pendingSupportPower)
            return (
                pendingSupportPower.displayName.uppercased(),
                [
                    "$\(pendingSupportPower.cost)  CD \(Int(pendingSupportPower.cooldown))s",
                    "Ready \(cooldown > 0 ? "\(Int(ceil(cooldown)))s" : "now")",
                    pendingSupportPower.repairAmount > 0
                        ? "Radius \(Int(pendingSupportPower.radius))  Repair \(Int(pendingSupportPower.repairAmount))"
                        : "Radius \(Int(pendingSupportPower.radius))  Dmg \(Int(pendingSupportPower.damage))",
                    supportAssetLine(for: pendingSupportPower, faction: .player)
                ]
            )
        }

        if isSettingRallyPoint {
            return rallyPointPendingInfoContent()
        }

        if isSettingAttackMove {
            let combatUnits = selected.filter {
                $0.faction == .player && $0.isAlive && !$0.kind.isStructure && $0.kind.damage > 0
            }
            if activeMissionStage() == .destroyHQ, let redHQ = playerKnownEnemyHQ() {
                return (
                    "ATTACK MOVE",
                    attackMoveHQTargetRows(combatUnits: combatUnits, redHQ: redHQ)
                )
            }
            return (
                "ATTACK MOVE",
                [
                    "Combat units \(combatUnits.count)",
                    "Seek radius \(Int(attackMoveEngagementRadius))",
                    "Engage visible enemies en route",
                    "Tap map to push formation"
                ]
            )
        }

        if selected.isEmpty {
            return (
                "BATTLEFIELD",
                [
                    "Blue \(mobileCount(for: .player))  Red \(mobileCount(for: .enemy))",
                    "Income +$\(incomePerTick(for: .player))/s  Flags \(controlPointCount(for: .player))",
                    "AI \(aiDifficulty.displayName)  Enemy $\(enemyMoney)",
                    playerQueueInfoLine()
                ]
            )
        }

        if selected.count == 1, let entity = selected.first {
            return singleSelectionInfo(for: entity)
        }

        return groupSelectionInfo(for: selected)
    }

    private func rallyPointPendingInfoContent() -> (title: String, rows: [String]) {
        let sources = selectedPlayerRallyFactories()
        let land = sources.filter { rallyDomain(for: $0.kind) == .land }.count
        let air = sources.filter { rallyDomain(for: $0.kind) == .air }.count
        let naval = sources.filter { rallyDomain(for: $0.kind) == .naval }.count
        let setCount = sources.filter { $0.rallyPoint != nil }.count

        return (
            "RALLY POINT",
            [
                "Sources \(sources.count)",
                "Land \(land)  Air \(air)  Naval \(naval)",
                "Rally set \(setCount)  Unset \(sources.count - setCount)",
                "Tap map to set rally"
            ]
        )
    }

    private func attackMoveHQTargetRows(combatUnits: [GameEntity], redHQ: GameEntity) -> [String] {
        let nearestDistance = combatUnits
            .map { $0.node.position.distance(to: redHQ.node.position) }
            .min()
        return [
            "Combat units \(combatUnits.count)",
            "Red HQ HP \(Int(redHQ.hp))/\(Int(redHQ.kind.maxHP))",
            nearestDistance.map { "Nearest approx \(Int($0))" } ?? "Select combat units",
            "Tap map to push formation"
        ]
    }

    private func singleSelectionInfo(for entity: GameEntity) -> (title: String, rows: [String]) {
        let hpPercent = Int((entity.hp / max(entity.kind.maxHP, 1)) * 100)
        var rows = [
            "HP \(Int(entity.hp))/\(Int(entity.kind.maxHP))  \(hpPercent)%",
            "Atk \(Int(effectiveDamage(for: entity)))  Rng \(Int(entity.kind.attackRange))  Vis \(effectiveVisionTiles(for: entity))",
            "Move \(Int(entity.kind.speed))  \(domainLabel(for: entity.kind.domain))",
            "$\(entity.kind.cost)  Value \(Int(strategicValue(of: entity.kind)))"
        ]

        if entity.kind.isStructure {
            if !entity.isOperational {
                rows[1] = "Atk 0  Rng 0  Vis 0"
            }
            rows[2] = entity.isOperational ? "Operational  \(domainLabel(for: entity.kind.domain))" : "Build \(Int(ceil(entity.buildProgressRemaining)))s left"
            rows[3] = structureStatusLine(for: entity)
            applyCoastalAssetInfo(for: entity, rows: &rows)
        } else {
            rows[3] = veterancyProgressLine(for: entity)
            if entity.kind == .carrier {
                let escortLine = highValueNavalEscortLine(for: entity).map { "  \($0)" } ?? ""
                rows[2] = "\(carrierDeckCapabilityLine())\(escortLine)"
                let wingLine = carrierAirWingLine(for: entity).map { "  \($0)" } ?? ""
                rows[3] = "\(carrierDeckQueueAndRallyLine(for: entity))\(wingLine)"
            } else {
                if let escortLine = highValueNavalEscortLine(for: entity) {
                    rows[2] = "\(rows[2])  \(escortLine)"
                }
                if let status = mobileStatusLine(for: entity) {
                    rows[2] = "\(rows[2])  \(compactVeterancyLine(for: entity))"
                    rows[3] = status
                } else if let threatSummary = airDefenseThreatSummaryLine(for: [entity]) {
                    rows[3] = threatSummary
                }
            }
        }
        if let capabilityInfo = selectionCapabilityInfoLine(for: entity) {
            rows[1] = "\(rows[1])  \(capabilityInfo)"
        }

        return ("\(entity.kind.displayName) \(entity.kind.shortCode)", rows)
    }

    private func applyCoastalAssetInfo(for entity: GameEntity, rows: inout [String]) {
        guard let roleLine = coastalAssetRoleLine(for: entity),
              let missionLine = coastalAssetMissionLine(for: entity) else { return }

        if entity.isOperational {
            rows[2] = roleLine
            rows[3] = missionLine
        } else {
            rows[1] = roleLine
            rows[3] = missionLine
        }
    }

    private func coastalAssetRoleLine(for entity: GameEntity) -> String? {
        switch entity.kind {
        case .shipyard:
            let queue = entity.isOperational ? "  \(compactProductionStatusLine(for: entity))" : ""
            return "Builds BB/SUB/CV\(queue)"
        case .sonarBuoy:
            return "Coastal sonar  No SCAN"
        case .coastalBattery:
            return "Coastal anti-ship  No sonar"
        default:
            return nil
        }
    }

    private func coastalAssetMissionLine(for entity: GameEntity) -> String? {
        guard isCoastalAssetKind(entity.kind) else { return nil }
        let state: String
        if entity.faction == .player {
            state = entity.isAlive && entity.isOperational ? "counted" : "pending"
        } else {
            state = "not counted"
        }
        return "Secure Coast: \(state)"
    }

    private func isCoastalAssetKind(_ kind: EntityKind) -> Bool {
        kind == .shipyard || kind == .sonarBuoy || kind == .coastalBattery
    }

    private func compactProductionStatusLine(for entity: GameEntity) -> String {
        let orders = buildOrders.filter { $0.sourceID == entity.id }
        guard let active = orders.first else {
            return entity.kind.supportsRallyPoint ? "Q idle Rally" : "Q idle"
        }
        let suffix = orders.count > 1 ? "+\(orders.count - 1)" : ""
        return "Q \(active.kind.shortCode) \(Int(ceil(active.remaining)))s\(suffix)"
    }

    private func carrierDeckCapabilityLine() -> String {
        "Deck HEL/JET"
    }

    private func carrierDeckQueueAndRallyLine(for entity: GameEntity) -> String {
        let rally = entity.rallyPoint == nil ? "Rally unset" : "Rally set"
        let orders = buildOrders.filter { $0.sourceID == entity.id }
        guard let active = orders.first else {
            return "\(rally)  Queue idle"
        }
        let suffix = orders.count > 1 ? " +\(orders.count - 1)" : ""
        return "\(rally)  Queue \(active.kind.shortCode) \(Int(ceil(active.remaining)))s\(suffix)"
    }

    private func carrierAirWingLine(for entity: GameEntity) -> String? {
        guard entity.kind == .carrier else { return nil }
        let requirement = carrierGuardWingRequirement
        let nearbyWing = nearbyCarrierAirWing(for: entity)
        let isGuarding = entity.holdPosition != nil
        let guardWing = isGuarding ? boundCarrierGuardWing(for: entity) : []
        let count = isGuarding ? guardWing.count : nearbyWing.count
        let missing = max(0, requirement - count)
        let label = isGuarding ? "GW" : "Wing"
        let compositionSuffix = carrierAirWingCompositionSuffix(for: isGuarding ? guardWing : nearbyWing)
        let contactSuffix: String
        if isGuarding {
            let contactSummary = carrierGuardContactSummary(for: entity, guardWing: guardWing)
            let engagedCount = carrierGuardEngagedCount(for: entity, guardWing: guardWing)
            let engagedSuffix = engagedCount > 0 ? " Eng \(engagedCount)" : ""
            if contactSummary.count > 0 {
                let typeSuffix = contactSummary.type.map { " \($0)" } ?? ""
                let targetSuffix = contactSummary.targetCode.map { " Tgt \($0)" } ?? ""
                contactSuffix = " C\(contactSummary.count)\(typeSuffix)\(targetSuffix)\(engagedSuffix)"
            } else {
                contactSuffix = " C0\(engagedSuffix)"
            }
        } else {
            contactSuffix = ""
        }
        if missing > 0 {
            return "\(label) \(count)/\(requirement) Need \(missing)\(compositionSuffix)\(contactSuffix)"
        }
        return "\(label) \(count)/\(requirement) OK\(compositionSuffix)\(contactSuffix)"
    }

    private func carrierAirWingCompositionSuffix(for wing: [GameEntity]) -> String {
        let helicopterCount = wing.filter { $0.kind == .helicopter }.count
        let fighterCount = wing.filter { $0.kind == .fighter }.count
        var parts: [String] = []
        if helicopterCount > 0 {
            parts.append("H\(helicopterCount)")
        }
        if fighterCount > 0 {
            parts.append("J\(fighterCount)")
        }
        guard !parts.isEmpty else { return "" }
        return " \(parts.joined(separator: " "))"
    }

    private func carrierGuardEngagedCount(for carrier: GameEntity, guardWing: [GameEntity]) -> Int {
        guard carrier.kind == .carrier, carrier.holdPosition != nil else { return 0 }
        return guardWing.reduce(0) { total, wing in
            guard let holdPosition = wing.holdPosition,
                  let target = wing.attackTarget,
                  isCarrierGuardContact(target, for: wing, carrier: carrier, holdPosition: holdPosition)
            else { return total }
            return total + 1
        }
    }

    private func boundCarrierGuardWing(for carrier: GameEntity) -> [GameEntity] {
        nearbyCarrierAirWing(for: carrier).filter { wing in
            wing.holdPosition != nil && wing.guardAnchorCarrierID == carrier.id
        }
    }

    private func carrierGuardContactSummary(for carrier: GameEntity, guardWing: [GameEntity]) -> (count: Int, type: String?, targetCode: String?) {
        var contactIDs = Set<Int>()
        var contactTypes = Set<String>()
        var preferredTarget: GameEntity?
        var preferredPriority = Int.max
        var preferredDistance = CGFloat.greatestFiniteMagnitude
        for wing in guardWing {
            guard let holdPosition = wing.holdPosition else { continue }
            for target in entities.values where isCarrierGuardContact(target, for: wing, carrier: carrier, holdPosition: holdPosition) {
                if contactIDs.insert(target.id).inserted {
                    contactTypes.insert(carrierGuardContactType(for: target))
                }
                let priority = carrierGuardTargetPriority(for: wing, target: target)
                let distance = target.node.position.distance(to: carrier.node.position)
                if preferredTarget == nil ||
                    priority < preferredPriority ||
                    (priority == preferredPriority && distance < preferredDistance - 0.5) ||
                    (priority == preferredPriority && abs(distance - preferredDistance) < 0.5 && target.id < (preferredTarget?.id ?? Int.max)) {
                    preferredTarget = target
                    preferredPriority = priority
                    preferredDistance = distance
                }
            }
        }
        let type: String?
        if contactIDs.isEmpty {
            type = nil
        } else if contactTypes.count == 1 {
            type = contactTypes.first
        } else {
            type = "Mix"
        }
        let targetCode = contactIDs.isEmpty ? nil : preferredTarget?.kind.shortCode
        return (contactIDs.count, type, targetCode)
    }

    private func carrierGuardContactType(for target: GameEntity) -> String {
        if target.kind == .submarine {
            return "Sub"
        }
        switch target.kind.domain {
        case .air:
            return "Air"
        case .naval:
            return "Sea"
        case .land, .structure:
            return "Ground"
        }
    }

    private func nearbyCarrierAirWingCount(for entity: GameEntity) -> Int {
        nearbyCarrierAirWing(for: entity).count
    }

    private func nearbyCarrierAirWing(for entity: GameEntity) -> [GameEntity] {
        entities.values.filter { wing in
            wing.faction == entity.faction &&
                wing.isAlive &&
                wing.isOperational &&
                !wing.kind.isStructure &&
                (wing.kind == .helicopter || wing.kind == .fighter) &&
                wing.node.position.distance(to: entity.node.position) <= highValueNavalEscortRadius
        }
    }

    private func highValueNavalEscortRequirement(for kind: EntityKind) -> Int? {
        switch kind {
        case .battleship:
            return 1
        case .carrier:
            return 2
        default:
            return nil
        }
    }

    private func highValueNavalEscortLine(for entity: GameEntity) -> String? {
        guard let requirement = highValueNavalEscortRequirement(for: entity.kind) else { return nil }
        let escorts = nearbyNavalEscorts(for: entity)
        let nearby = escorts.count
        let missing = max(0, requirement - nearby)
        if missing > 0 {
            return "Escort \(nearby)/\(requirement) Need \(missing) \(highValueNavalEscortNeedType(for: escorts))"
        }
        return "Escort \(nearby)/\(requirement) OK"
    }

    private func nearbyNavalEscortCount(for entity: GameEntity) -> Int {
        nearbyNavalEscorts(for: entity).count
    }

    private func nearbyNavalEscorts(for entity: GameEntity) -> [GameEntity] {
        entities.values.filter { escort in
            escort.faction == entity.faction &&
                escort.isAlive &&
                escort.id != entity.id &&
                !escort.kind.isStructure &&
                escort.kind.damage > 0 &&
                escort.isOperational &&
                highValueNavalEscortRequirement(for: escort.kind) == nil &&
                escort.node.position.distance(to: entity.node.position) <= highValueNavalEscortRadius
        }
    }

    private func highValueNavalEscortNeedType(for escorts: [GameEntity]) -> String {
        if !escorts.contains(where: { $0.kind.domain == .air }) {
            return "Air"
        }
        if !escorts.contains(where: { $0.kind.domain == .naval }) {
            return "Sea"
        }
        if !escorts.contains(where: { $0.kind.domain == .land }) {
            return "Ground"
        }
        return "Mix"
    }

    private func groupHighValueNavalEscortSummary(for selected: [GameEntity]) -> String? {
        guard selected.count > 1 else { return nil }
        let highValueNaval = selected.compactMap { entity -> (nearby: Int, required: Int, needType: String?)? in
            guard entity.faction == .player,
                  let required = highValueNavalEscortRequirement(for: entity.kind) else { return nil }
            let escorts = nearbyNavalEscorts(for: entity)
            let nearby = escorts.count
            let missing = max(0, required - nearby)
            let needType = missing > 0 ? highValueNavalEscortNeedType(for: escorts) : nil
            return (nearby, required, needType)
        }
        guard !highValueNaval.isEmpty else { return nil }

        let satisfied = highValueNaval.filter { $0.nearby >= $0.required }.count
        let missing = highValueNaval.reduce(0) { total, item in
            total + max(0, item.required - item.nearby)
        }
        if missing > 0 {
            let needTypes = Set(highValueNaval.compactMap { $0.needType })
            let typeSummary = needTypes.count == 1 ? (needTypes.first ?? "Mix") : "Mix"
            return "HV Navy \(satisfied)/\(highValueNaval.count) escorted  Need \(missing) \(typeSummary)"
        }
        return "HV Navy \(satisfied)/\(highValueNaval.count) escorted"
    }

    private func groupCarrierGuardWingSummary(for selected: [GameEntity]) -> String? {
        guard selected.count > 1 else { return nil }
        let carriers = selected.filter { entity in
            entity.faction == .player &&
                entity.kind == .carrier &&
                entity.isAlive &&
                entity.holdPosition != nil
        }
        guard !carriers.isEmpty else { return nil }

        var boundWingCount = 0
        var requiredWingCount = 0
        var guardWings: [GameEntity] = []
        var contactIDs = Set<Int>()
        var contactTypes = Set<String>()
        var preferredTarget: GameEntity?
        var preferredPriority = Int.max
        var preferredDistance = CGFloat.greatestFiniteMagnitude
        var engagedCount = 0
        for carrier in carriers {
            let guardWing = boundCarrierGuardWing(for: carrier)
            guardWings.append(contentsOf: guardWing)
            boundWingCount += guardWing.count
            requiredWingCount += carrierGuardWingRequirement
            engagedCount += carrierGuardEngagedCount(for: carrier, guardWing: guardWing)
            for wing in guardWing {
                guard let holdPosition = wing.holdPosition else { continue }
                for target in entities.values where isCarrierGuardContact(target, for: wing, carrier: carrier, holdPosition: holdPosition) {
                    if contactIDs.insert(target.id).inserted {
                        contactTypes.insert(carrierGuardContactType(for: target))
                    }
                    let priority = carrierGuardTargetPriority(for: wing, target: target)
                    let distance = target.node.position.distance(to: carrier.node.position)
                    if preferredTarget == nil ||
                        priority < preferredPriority ||
                        (priority == preferredPriority && distance < preferredDistance - 0.5) ||
                        (priority == preferredPriority && abs(distance - preferredDistance) < 0.5 && target.id < (preferredTarget?.id ?? Int.max)) {
                        preferredTarget = target
                        preferredPriority = priority
                        preferredDistance = distance
                    }
                }
            }
        }

        let missing = max(0, requiredWingCount - boundWingCount)
        let readiness = missing > 0 ? "Need \(missing)" : "OK"
        let compositionSuffix = carrierAirWingCompositionSuffix(for: guardWings)
        let contactTypeSuffix: String
        if contactIDs.isEmpty {
            contactTypeSuffix = ""
        } else if contactTypes.count == 1 {
            contactTypeSuffix = " \(contactTypes.first ?? "Mix")"
        } else {
            contactTypeSuffix = " Mix"
        }
        let targetSuffix = contactIDs.isEmpty ? "" : preferredTarget.map { " Tgt \($0.kind.shortCode)" } ?? ""
        let engagedSuffix = engagedCount > 0 ? " Eng \(engagedCount)" : ""
        return "CV GW \(boundWingCount)/\(requiredWingCount) \(readiness)\(compositionSuffix) C\(contactIDs.count)\(contactTypeSuffix)\(targetSuffix)\(engagedSuffix)"
    }

    private func groupSelectionInfo(for selected: [GameEntity]) -> (title: String, rows: [String]) {
        let land = selected.filter { $0.kind.domain == .land }.count
        let air = selected.filter { $0.kind.domain == .air }.count
        let naval = selected.filter { $0.kind.domain == .naval }.count
        let totalHP = selected.reduce(CGFloat.zero) { $0 + $1.hp }
        let totalMaxHP = selected.reduce(CGFloat.zero) { $0 + $1.kind.maxHP }
        let totalDamage = selected.reduce(CGFloat.zero) { $0 + effectiveDamage(for: $1) }
        let maxRange = selected.map { $0.kind.attackRange }.max() ?? 0
        let holdingCount = selected.filter { $0.holdPosition != nil }.count
        let attackMoveCount = selected.filter { $0.attackMoveDestination != nil }.count
        let highValueEscortSummary = groupHighValueNavalEscortSummary(for: selected)
        let carrierGuardWingSummary = groupCarrierGuardWingSummary(for: selected)
        let selectedCarrierGuardWingSummary = groupSelectedCarrierGuardWingSummary(for: selected)
        let airDefenseThreatSummary = airDefenseThreatSummaryLine(for: selected)
        let combatSummary = groupAntiSubmarineSummary(for: selected).map {
            "Dmg \(Int(totalDamage))  Max rng \(Int(maxRange))  \($0)"
        } ?? "Dmg \(Int(totalDamage))  Max rng \(Int(maxRange))"

        return (
            "\(selected.count) UNITS SELECTED",
            [
                "Land \(land)  Air \(air)  Sea \(naval)",
                "HP \(Int(totalHP))/\(Int(totalMaxHP))",
                combatSummary,
                holdingCount > 0
                    ? "Holding \(holdingCount)  \(carrierGuardWingSummary ?? selectedCarrierGuardWingSummary ?? "Guard \(Int(holdEngagementRadius))")"
                    : attackMoveCount > 0
                        ? "Attack move \(attackMoveCount)  Seek \(Int(attackMoveEngagementRadius))"
                        : focusFireSummaryLine(for: selected)
                            ?? airDefenseThreatSummary
                            ?? highValueEscortSummary
                            ?? groupVeterancyLine(for: selected)
            ]
        )
    }

    private func airDefenseThreatSummaryLine(for selected: [GameEntity]) -> String? {
        let selectedAir = selected.filter {
            $0.faction == .player && $0.isAlive && $0.kind.domain == .air
        }
        guard !selectedAir.isEmpty else { return nil }

        let threats = activeKnownAirDefenseThreats(for: selectedAir)
        guard !threats.isEmpty else { return "AA THR0 CLEAR C0/\(selectedAir.count)" }
        let samCount = threats.filter { $0.kind == .samSite }.count
        let mobileCount = threats.filter { $0.kind == .aaTruck }.count
        let coveredCount = selectedAir.filter { aircraft in
            threats.contains { isAirDefenseThreat($0, covering: aircraft) }
        }.count
        return "AA THR\(threats.count) S\(samCount) M\(mobileCount) C\(coveredCount)/\(selectedAir.count)"
    }

    private func activeKnownAirDefenseThreats(for selectedAir: [GameEntity]) -> [GameEntity] {
        entities.values
            .filter { threat in
                threat.faction == .enemy &&
                    threat.isAlive &&
                    threat.isOperational &&
                    (threat.kind == .samSite || threat.kind == .aaTruck) &&
                    isKnownToFaction(threat, observer: .player) &&
                    selectedAir.contains { isAirDefenseThreat(threat, covering: $0) }
            }
            .sorted { lhs, rhs in
                if lhs.kind == rhs.kind { return lhs.id < rhs.id }
                return lhs.kind == .samSite
            }
    }

    private func isAirDefenseThreat(_ threat: GameEntity, covering aircraft: GameEntity) -> Bool {
        aircraft.faction == .player &&
            aircraft.isAlive &&
            aircraft.kind.domain == .air &&
            threat.kind.canAttack(aircraft.kind) &&
            threat.node.position.distance(to: aircraft.node.position) <= threat.kind.attackRange + aircraft.kind.footprint * 0.35
    }

    private func veterancyProgressLine(for entity: GameEntity) -> String {
        if let nextThreshold = entity.nextVeterancyThreshold {
            return "Vet \(entity.veterancyRank.displayName) XP \(Int(entity.veterancyXP))/\(Int(nextThreshold)) Kills \(entity.killCount)"
        }
        return "Vet \(entity.veterancyRank.displayName) XP \(Int(entity.veterancyXP)) Kills \(entity.killCount)"
    }

    private func compactVeterancyLine(for entity: GameEntity) -> String {
        "\(entity.veterancyRank.shortCode) XP\(Int(entity.veterancyXP)) K\(entity.killCount)"
    }

    private func mobileStatusLine(for entity: GameEntity) -> String? {
        if entity.kind == .submarine {
            return submarineStatusLine(for: entity)
        }
        if entity.kind == .mechanic {
            return "Repair \(Int(mechanicRepairRange))  Damaged \(damagedRepairTargetCount(for: entity))"
        }
        if entity.kind == .carrier {
            return structureStatusLine(for: entity)
        }
        if let guardWingStatus = carrierGuardWingStatusLine(for: entity) {
            return guardWingStatus
        }
        if entity.attackMoveDestination != nil {
            return "Attack-moving  Seek \(Int(attackMoveEngagementRadius))"
        }
        if entity.holdPosition != nil {
            return "Holding position  Guard \(Int(holdEngagementRadius))"
        }
        if let repairSource = damagedMobileRepairSourceLine(for: entity) {
            return repairSource
        }
        return nil
    }

    private func carrierGuardWingStatusLine(for wing: GameEntity) -> String? {
        guard wing.faction == .player,
              wing.kind == .helicopter || wing.kind == .fighter,
              let carrier = carrierGuardAnchor(for: wing)
        else { return nil }

        let distance = wing.node.position.distance(to: carrier.node.position)
        let targetSuffix: String
        if let target = carrierGuardPriorityTarget(for: wing) {
            targetSuffix = " Tgt \(target.kind.shortCode) \(carrierGuardContactType(for: target))"
        } else {
            targetSuffix = ""
        }
        return "CV GUARD D\(Int(distance))\(targetSuffix)  Guard \(Int(holdEngagementRadius))"
    }

    private func groupSelectedCarrierGuardWingSummary(for selected: [GameEntity]) -> String? {
        guard selected.count > 1 else { return nil }
        let guardWingsAndDistances = selected.compactMap { wing -> (wing: GameEntity, distance: CGFloat)? in
            guard wing.faction == .player,
                  wing.kind == .helicopter || wing.kind == .fighter,
                  let carrier = carrierGuardAnchor(for: wing)
            else { return nil }
            return (wing, wing.node.position.distance(to: carrier.node.position))
        }
        guard let nearestDistance = guardWingsAndDistances.map({ $0.distance }).min() else { return nil }
        let guardWings = guardWingsAndDistances.map { $0.wing }
        let compositionSuffix = carrierAirWingCompositionSuffix(for: guardWings)
        let targetSuffix = carrierGuardWingTargetSuffix(for: guardWings)
        return "CV GUARD \(guardWings.count)\(compositionSuffix) D\(Int(nearestDistance))\(targetSuffix)"
    }

    private func carrierGuardWingTargetSuffix(for guardWings: [GameEntity]) -> String {
        var preferred: (target: GameEntity, priority: Int, distance: CGFloat)?
        for wing in guardWings {
            guard let carrier = carrierGuardAnchor(for: wing),
                  let target = carrierGuardPriorityTarget(for: wing)
            else { continue }
            let priority = carrierGuardTargetPriority(for: wing, target: target)
            let distance = target.node.position.distance(to: carrier.node.position)
            if let current = preferred {
                guard priority < current.priority ||
                    (priority == current.priority && distance < current.distance - 0.5) ||
                    (priority == current.priority && abs(distance - current.distance) < 0.5 && target.id < current.target.id)
                else { continue }
            }
            preferred = (target, priority, distance)
        }
        guard let target = preferred?.target else { return "" }
        return " Tgt \(target.kind.shortCode) \(carrierGuardContactType(for: target))"
    }

    private func submarineStatusLine(for entity: GameEntity) -> String {
        if entity.revealedUntil > lastUpdateTime {
            return "Temporary detected \(Int(ceil(entity.revealedUntil - lastUpdateTime)))s"
        }
        if entity.faction == .player {
            return isCoveredByKnownEnemySonar(entity) ? "Known sonar contact" : "Stealth / no known contact"
        }
        return "Stealth while undetected"
    }

    private func isCoveredByKnownEnemySonar(_ submarine: GameEntity) -> Bool {
        guard submarine.kind == .submarine,
              submarine.faction == .player,
              submarine.isAlive else { return false }

        return entities.values.contains { sensor in
            sensor.faction == .enemy &&
                isActiveSonarSensor(sensor) &&
                isKnownToFaction(sensor, observer: .player) &&
                sensor.node.position.distance(to: submarine.node.position) <= sonarRange(for: sensor.kind)
        }
    }

    private func damagedRepairTargetCount(for mechanic: GameEntity) -> Int {
        guard mechanic.kind == .mechanic,
              mechanic.isAlive else { return 0 }
        return entities.values.filter { target in
            target.faction == mechanic.faction &&
                target.isAlive &&
                target.id != mechanic.id &&
                target.hp < target.kind.maxHP &&
                target.node.position.distance(to: mechanic.node.position) < mechanicRepairRange
        }.count
    }

    private func damagedMobileRepairSourceLine(for entity: GameEntity) -> String? {
        guard entity.faction == .player,
              entity.isAlive,
              !entity.kind.isStructure,
              entity.kind != .mechanic,
              entity.hp < entity.kind.maxHP else { return nil }

        guard let distance = nearestFriendlyMechanicDistance(for: entity) else {
            return "Need MECH"
        }
        if distance < mechanicRepairRange {
            return "MECH in range"
        }
        return "Need MECH  \(Int(distance))"
    }

    private func nearestFriendlyMechanicDistance(for entity: GameEntity) -> CGFloat? {
        entities.values
            .filter { mechanic in
                mechanic.faction == entity.faction &&
                    mechanic.isAlive &&
                    mechanic.kind == .mechanic
            }
            .map { $0.node.position.distance(to: entity.node.position) }
            .min()
    }

    private func groupVeterancyLine(for selected: [GameEntity]) -> String {
        let recruit = selected.filter { $0.veterancyRank == .recruit }.count
        let hardened = selected.filter { $0.veterancyRank == .hardened }.count
        let veteran = selected.filter { $0.veterancyRank == .veteran }.count
        let elite = selected.filter { $0.veterancyRank == .elite }.count
        let totalKills = selected.reduce(0) { $0 + $1.killCount }
        return "Vet R\(recruit) H\(hardened) V\(veteran) E\(elite)  Kills \(totalKills)"
    }

    private func structureStatusLine(for entity: GameEntity) -> String {
        if entity.kind.isStructure && !entity.isOperational {
            return "Offline until operational"
        }
        guard entity.kind.isFactory else {
            if entity.kind == .oilDerrick {
                return "Income +$145/s when held"
            }
            if entity.kind == .radarOutpost {
                return "Radar vision \(entity.kind.visionTiles)  SCAN asset"
            }
            if entity.kind == .sonarBuoy {
                return "Sonar \(Int(sonarRange(for: entity.kind)))  No SCAN"
            }
            if entity.kind == .guardTower {
                return "Land/Air defense  No naval"
            }
            if entity.kind == .samSite {
                return "Anti-air defense"
            }
            if entity.kind == .coastalBattery {
                return "Naval defense  No sonar"
            }
            return "Build coverage"
        }

        let orders = buildOrders.filter { $0.sourceID == entity.id }
        guard let active = orders.first else {
            return entity.kind.supportsRallyPoint ? "Queue idle  Rally ready" : "Queue idle"
        }
        let suffix = orders.count > 1 ? " +\(orders.count - 1)" : ""
        return "Queue \(active.kind.shortCode) \(Int(ceil(active.remaining)))s\(suffix)"
    }

    private func isActiveSonarSensor(_ entity: GameEntity) -> Bool {
        entity.kind.hasSonar &&
            entity.isAlive &&
            (!entity.kind.isStructure || entity.isOperational)
    }

    private func isActiveAntiSubmarineAttacker(_ entity: GameEntity) -> Bool {
        entity.isAlive &&
            entity.kind.canAttack(.submarine) &&
            (!entity.kind.isStructure || entity.isOperational)
    }

    private func selectionCapabilityInfoLine(for entity: GameEntity) -> String? {
        var parts: [String] = []
        let hasASWAttack = isActiveAntiSubmarineAttacker(entity)
        if hasASWAttack {
            parts.append("ASW attack")
        }
        if let sonarInfo = sonarInfoLine(for: entity) {
            parts.append(sonarInfo)
        } else if hasASWAttack {
            parts.append("No sonar")
        }
        return parts.isEmpty ? nil : parts.joined(separator: "  ")
    }

    private func sonarInfoLine(for entity: GameEntity) -> String? {
        guard isActiveSonarSensor(entity) else { return nil }
        let range = Int(sonarRange(for: entity.kind))
        if entity.faction == .player {
            return "Sonar \(range) Ctc \(sonarContactCount(for: entity))"
        }
        return "Sonar \(range)"
    }

    private func sonarContactCount(for sensor: GameEntity) -> Int {
        guard sensor.faction == .player,
              isActiveSonarSensor(sensor) else { return 0 }
        let range = sonarRange(for: sensor.kind)
        return entities.values.filter { contact in
            contact.kind == .submarine &&
                contact.faction == .enemy &&
                contact.isAlive &&
                isKnownToFaction(contact, observer: .player) &&
                sensor.node.position.distance(to: contact.node.position) <= range
        }.count
    }

    private func groupAntiSubmarineSummary(for selected: [GameEntity]) -> String? {
        let aswAttackers = selected.filter(isActiveAntiSubmarineAttacker)
        let sensors = selected.filter(isActiveSonarSensor)
        guard !aswAttackers.isEmpty || !sensors.isEmpty else { return nil }
        let maxRange = sensors.map { sonarRange(for: $0.kind) }.max() ?? 0
        var summary = "ASW \(aswAttackers.count)  Sonar \(sensors.count)/\(Int(maxRange))"
        let playerSensors = sensors.filter { $0.faction == .player }
        if !playerSensors.isEmpty {
            summary += "  Ctc \(groupSonarContactCount(for: playerSensors))"
        }
        return summary
    }

    private func groupSonarContactCount(for sensors: [GameEntity]) -> Int {
        let playerSensors = sensors.filter { sensor in
            sensor.faction == .player && isActiveSonarSensor(sensor)
        }
        guard !playerSensors.isEmpty else { return 0 }

        var contactIDs = Set<Int>()
        for contact in entities.values {
            guard contact.kind == .submarine,
                  contact.faction == .enemy,
                  contact.isAlive,
                  isKnownToFaction(contact, observer: .player) else { continue }

            let isCovered = playerSensors.contains { sensor in
                sensor.node.position.distance(to: contact.node.position) <= sonarRange(for: sensor.kind)
            }
            if isCovered {
                contactIDs.insert(contact.id)
            }
        }
        return contactIDs.count
    }

    private func playerQueueInfoLine() -> String {
        let playerQueue = buildOrders.filter { $0.faction == .player }
        guard !playerQueue.isEmpty else { return "Queue idle" }
        let summary = playerQueue.prefix(2).map { "\($0.kind.shortCode) \(Int(ceil($0.remaining)))s" }.joined(separator: " ")
        return "Queue \(summary)"
    }

    private func supportAssetLine(for power: SupportPower, faction: Faction) -> String {
        let requirement = supportAssetRequirementLabel(for: power)
        if hasOperationalSupportAsset(for: power, faction: faction) {
            return "Asset ready: \(requirement)"
        }
        return "Need \(requirement)"
    }

    private func supportAssetRequirementLabel(for power: SupportPower) -> String {
        switch power {
        case .reconSweep:
            return "HQ/RAD"
        case .fieldRepair:
            return "HQ/MECH"
        case .airStrike:
            return "AF/CV"
        case .navalBarrage:
            return "BB/CV"
        }
    }

    private func domainLabel(for domain: Domain) -> String {
        switch domain {
        case .land:
            return "Land"
        case .air:
            return "Air"
        case .naval:
            return "Naval"
        case .structure:
            return "Structure"
        }
    }

    private func minimapPoint(forWorldPoint point: CGPoint) -> CGPoint {
        guard worldBounds.width > 0 && worldBounds.height > 0 else {
            return CGPoint(x: minimapFrame.midX, y: minimapFrame.midY)
        }
        let xRatio = (point.x - worldBounds.minX) / worldBounds.width
        let yRatio = (point.y - worldBounds.minY) / worldBounds.height
        return CGPoint(
            x: minimapFrame.minX + min(max(xRatio, 0), 1) * minimapFrame.width,
            y: minimapFrame.minY + min(max(yRatio, 0), 1) * minimapFrame.height
        )
    }

    private func worldPoint(fromMinimap point: CGPoint) -> CGPoint {
        let xRatio = min(max((point.x - minimapFrame.minX) / minimapFrame.width, 0), 1)
        let yRatio = min(max((point.y - minimapFrame.minY) / minimapFrame.height, 0), 1)
        return CGPoint(
            x: worldBounds.minX + xRatio * worldBounds.width,
            y: worldBounds.minY + yRatio * worldBounds.height
        )
    }

    private func updateMinimap() {
        guard minimapFrame.width > 0 else { return }
        minimapBlipsNode.removeAllChildren()

        for entity in entities.values where entity.isAlive {
            if entity.faction == .enemy && !isKnownToFaction(entity, observer: .player) {
                continue
            }
            let blip = minimapBlipNode(for: entity)
            blip.position = minimapPoint(forWorldPoint: entity.node.position)
            minimapBlipsNode.addChild(blip)
        }

        for point in controlPoints {
            let blip = SKShapeNode(rectOf: CGSize(width: 6.5, height: 6.5), cornerRadius: 1.2)
            blip.position = minimapPoint(forWorldPoint: point.node.position)
            blip.fillColor = controlPointColor(for: point.faction)
            blip.strokeColor = UIColor.white.withAlphaComponent(0.75)
            blip.lineWidth = 0.8
            minimapBlipsNode.addChild(blip)
        }

        let visibleWidth = size.width * cameraRig.xScale
        let visibleHeight = size.height * cameraRig.yScale
        let boxWidth = max(22, minimapFrame.width * min(1, visibleWidth / max(worldBounds.width, 1)))
        let boxHeight = max(18, minimapFrame.height * min(1, visibleHeight / max(worldBounds.height, 1)))
        minimapCameraBox.path = CGPath(
            rect: CGRect(x: -boxWidth / 2, y: -boxHeight / 2, width: boxWidth, height: boxHeight),
            transform: nil
        )
        minimapCameraBox.position = minimapPoint(forWorldPoint: cameraRig.position)
    }

    private func minimapBlipNode(for entity: GameEntity) -> SKNode {
        let node = SKNode()
        let color = minimapBlipColor(for: entity)
        let symbol: SKShapeNode
        let selectionRadius: CGFloat

        switch entity.kind.domain {
        case .structure:
            symbol = SKShapeNode(rectOf: CGSize(width: 6.6, height: 6.6), cornerRadius: 1.1)
            selectionRadius = 5.2
        case .land:
            symbol = SKShapeNode(circleOfRadius: 2.6)
            selectionRadius = 4.6
        case .air:
            symbol = SKShapeNode(path: trianglePath(size: 6.8))
            selectionRadius = 4.9
        case .naval:
            let isHighValue = entity.kind == .battleship || entity.kind == .carrier
            let width: CGFloat = isHighValue ? 8.8 : 7.2
            let height: CGFloat = isHighValue ? 6.4 : 5.0
            symbol = SKShapeNode(path: diamondPath(width: width, height: height))
            selectionRadius = isHighValue ? 5.8 : 5.0
        }

        symbol.fillColor = color
        symbol.strokeColor = UIColor.black.withAlphaComponent(0.58)
        symbol.lineWidth = 0.8

        if entity.kind == .submarine {
            symbol.fillColor = color.withAlphaComponent(0.18)
            symbol.strokeColor = color
            symbol.lineWidth = 1.4
        } else if entity.kind == .battleship || entity.kind == .carrier {
            symbol.strokeColor = UIColor.white.withAlphaComponent(0.88)
            symbol.lineWidth = 1.2
        }

        node.addChild(symbol)

        if selectedIDs.contains(entity.id) {
            let selectionRing = SKShapeNode(circleOfRadius: selectionRadius)
            selectionRing.fillColor = .clear
            selectionRing.strokeColor = UIColor(red: 0.78, green: 0.98, blue: 1.0, alpha: 1.0)
            selectionRing.lineWidth = 1.25
            selectionRing.glowWidth = 0.7
            selectionRing.zPosition = -1
            node.addChild(selectionRing)
        }

        return node
    }

    private func minimapBlipColor(for entity: GameEntity) -> UIColor {
        if entity.kind == .oilDerrick && entity.faction == .neutral {
            return UIColor(red: 0.98, green: 0.76, blue: 0.20, alpha: 1.0)
        }
        return entity.faction.color
    }

    private func beginPinchPan(with touches: Set<UITouch>) {
        guard let metrics = pinchMetrics(from: touches) else { return }
        touchStartScene = metrics.center
        touchStartWorld = nil
        panStartCamera = cameraRig.position
        pinchStartDistance = metrics.distance
        pinchStartScale = cameraRig.xScale
        isPanning = true
        isBoxSelecting = false
        selectionBoxNode?.removeFromParent()
        selectionBoxNode = nil
    }

    private func updatePinchPan(with touches: Set<UITouch>) {
        guard let metrics = pinchMetrics(from: touches) else { return }
        if pinchStartDistance == nil || touchStartScene == nil || panStartCamera == nil {
            beginPinchPan(with: touches)
        }
        guard let startCenter = touchStartScene,
              let panStart = panStartCamera,
              let startDistance = pinchStartDistance,
              startDistance > 0
        else { return }

        let scale = min(maxCameraScale, max(minCameraScale, pinchStartScale * startDistance / metrics.distance))
        cameraRig.setScale(scale)

        let screenDelta = (metrics.center - startCenter) * scale
        cameraRig.position = clampCamera(panStart - screenDelta)
    }

    private func pinchMetrics(from touches: Set<UITouch>) -> (center: CGPoint, distance: CGFloat)? {
        let points = Array(touches.prefix(2)).map { $0.location(in: self) }
        guard points.count == 2 else { return nil }
        return ((points[0] + points[1]) / 2, points[0].distance(to: points[1]))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let activeTouches = event?.allTouches ?? touches
        let uiPoint = touch.location(in: hudNode)
        if activeTouches.count >= 2 {
            pendingSupportPower = nil
            beginPinchPan(with: activeTouches)
            return
        }
        if let page = hudPage(at: uiPoint) {
            handleHudPage(page)
            touchStartScene = nil
            touchStartWorld = nil
            return
        }
        if let action = hudAction(at: uiPoint) {
            handleHudAction(action, tapCount: touch.tapCount)
            touchStartScene = nil
            touchStartWorld = nil
            return
        }
        if minimapFrame.contains(uiPoint) {
            isUsingMinimap = true
            cameraRig.position = clampCamera(worldPoint(fromMinimap: uiPoint))
            touchStartScene = nil
            touchStartWorld = nil
            return
        }

        let scenePoint = touch.location(in: self)
        let worldPoint = touch.location(in: worldNode)
        if pendingConstructionKind != nil {
            updateConstructionPreview(at: worldPoint)
        }
        let startEntity = entity(at: worldPoint)
        touchStartScene = scenePoint
        touchStartWorld = worldPoint
        panStartCamera = cameraRig.position
        isPanning = false
        touchStartedOnEntity = startEntity != nil
        touchStartedOnPlayerEntity = startEntity?.faction == .player
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let activeTouches = event?.allTouches ?? touches
        if isUsingMinimap {
            let uiPoint = touch.location(in: hudNode)
            if minimapFrame.contains(uiPoint) {
                cameraRig.position = clampCamera(worldPoint(fromMinimap: uiPoint))
            }
            return
        }

        if activeTouches.count >= 2 {
            updatePinchPan(with: activeTouches)
            return
        }

        guard let start = touchStartScene, let startWorld = touchStartWorld, let panStart = panStartCamera else { return }

        let currentWorld = touch.location(in: worldNode)
        if pendingConstructionKind != nil && touches.count == 1 {
            updateConstructionPreview(at: currentWorld)
            return
        }

        if pendingConstructionKind == nil &&
            pendingSupportPower == nil &&
            !isSettingRallyPoint &&
            !isSettingAttackMove &&
            !touchStartedOnPlayerEntity &&
            touches.count == 1 {
            let selectionDistance = currentWorld.distance(to: startWorld)
            if selectionDistance > 18 {
                isBoxSelecting = true
                updateSelectionBox(from: startWorld, to: currentWorld)
                return
            }
        }

        if pendingSupportPower == nil && touches.count < 2 && (touchStartedOnEntity || !selectedMobilePlayerUnits().isEmpty) {
            return
        }

        let current = touch.location(in: self)
        let delta = current - start
        if abs(delta.x) + abs(delta.y) > 10 {
            isPanning = true
            cameraRig.position = clampCamera(panStart - delta)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let tapCount = touch.tapCount
        defer {
            touchStartScene = nil
            touchStartWorld = nil
            panStartCamera = nil
            pinchStartDistance = nil
            isPanning = false
            isUsingMinimap = false
            touchStartedOnEntity = false
            touchStartedOnPlayerEntity = false
            isBoxSelecting = false
            selectionBoxNode?.removeFromParent()
            selectionBoxNode = nil
        }

        if isUsingMinimap {
            let uiPoint = touch.location(in: hudNode)
            if minimapFrame.contains(uiPoint) {
                cameraRig.position = clampCamera(worldPoint(fromMinimap: uiPoint))
            }
            return
        }

        guard let startWorld = touchStartWorld else { return }

        if isBoxSelecting {
            selectUnits(in: normalizedRect(from: startWorld, to: touch.location(in: worldNode)))
            return
        }

        let worldPoint = touch.location(in: worldNode)
        if pendingConstructionKind != nil {
            updateConstructionPreview(at: worldPoint)
            if worldPoint.distance(to: startWorld) > 14 {
                return
            }
            handleWorldTap(at: worldPoint, tapCount: tapCount)
            return
        }

        if isPanning {
            return
        }

        if worldPoint.distance(to: startWorld) > 14 {
            return
        }
        handleWorldTap(at: worldPoint, tapCount: tapCount)
    }

    private func updateSelectionBox(from start: CGPoint, to end: CGPoint) {
        selectionBoxNode?.removeFromParent()
        let rect = normalizedRect(from: start, to: end)
        let shape = SKShapeNode(rect: rect)
        shape.fillColor = UIColor(red: 0.22, green: 0.65, blue: 1.0, alpha: 0.16)
        shape.strokeColor = UIColor(red: 0.38, green: 0.90, blue: 1.0, alpha: 1.0)
        shape.lineWidth = 2
        shape.zPosition = 420
        effectsLayer.addChild(shape)
        selectionBoxNode = shape
    }

    private func selectUnits(in rect: CGRect) {
        let expandedRect = rect.insetBy(dx: -18, dy: -18)
        let selected = entities.values.filter { entity in
            entity.faction == .player &&
            entity.isAlive &&
            !entity.kind.isStructure &&
            expandedRect.contains(entity.node.position)
        }
        selectedIDs = Set(selected.map(\.id))
        refreshSelection()
        if selected.isEmpty {
            showMessage("No units in selection box.", color: .white)
        } else {
            showMessage("Selected \(selected.count) units.", color: UIColor(red: 0.75, green: 0.95, blue: 1.0, alpha: 1.0))
        }
    }

    private func visibleWorldRect(padding: CGFloat = 28) -> CGRect {
        let width = size.width * cameraRig.xScale + padding * 2
        let height = size.height * cameraRig.yScale + padding * 2
        return CGRect(
            x: cameraRig.position.x - width / 2,
            y: cameraRig.position.y - height / 2,
            width: width,
            height: height
        )
    }

    private func selectVisiblePlayerUnits(matching tapped: GameEntity) {
        let viewRect = visibleWorldRect()
        let matches = entities.values.filter { entity in
            entity.faction == .player &&
            entity.isAlive &&
            !entity.kind.isStructure &&
            entity.kind == tapped.kind &&
            viewRect.contains(entity.node.position)
        }
        let selected = matches.isEmpty ? [tapped] : matches
        selectedIDs = Set(selected.map(\.id))
        refreshSelection()
        updateHUD()
        if selected.count > 1 {
            showMessage("Selected \(selected.count) \(tapped.kind.shortCode).", color: UIColor(red: 0.75, green: 0.95, blue: 1.0, alpha: 1.0))
        } else {
            showMessage("No other \(tapped.kind.shortCode) in view.", color: .white)
        }
    }

    private func normalizedRect(from start: CGPoint, to end: CGPoint) -> CGRect {
        CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
    }

    private func hudAction(at point: CGPoint) -> HudAction? {
        for (action, frame) in hudButtonFrames where frame.contains(point) {
            return action
        }
        return nil
    }

    private func hudPage(at point: CGPoint) -> HudPage? {
        for (page, frame) in hudPageFrames where frame.contains(point) {
            return page
        }
        return nil
    }

    private func handleHudPage(_ page: HudPage) {
        guard page != hudPage else { return }
        hudPage = page
        layoutHUD()
        updateHUD()
    }

    private func handleHudAction(_ action: HudAction, tapCount: Int = 1) {
        switch action {
        case .selectArmy:
            clearPendingCommandModes()
            selectedIDs = Set(entities.values.filter { $0.faction == .player && !$0.kind.isStructure && $0.isAlive }.map(\.id))
            refreshSelection()
            layoutHUD()
            updateHUD()
            showMessage("Selected all available combat units.", color: .white)
        case .controlGroup1:
            tapCount >= 2 ? saveControlGroup(1) : scheduleRecallControlGroup(1)
        case .controlGroup2:
            tapCount >= 2 ? saveControlGroup(2) : scheduleRecallControlGroup(2)
        case .holdPosition:
            clearPendingCommandModes()
            issueHoldPositionOrder(units: selectedMobilePlayerUnits())
        case .attackMove:
            clearPendingCommandModes()
            let combatUnits = selectedMobilePlayerUnits().filter { $0.kind.damage > 0 }
            guard !combatUnits.isEmpty else {
                isSettingAttackMove = false
                showMessage("Select combat units for attack move.", color: .orange)
                updateHUD()
                return
            }
            isSettingAttackMove = true
            refreshSelection()
            layoutHUD()
            updateHUD()
            if activeMissionStage() == .destroyHQ, let redHQ = playerKnownEnemyHQ() {
                showObjectiveTargetMarker(at: redHQ.node.position, label: "HQ")
                showMessage("Red HQ known: tap HQ or map for attack-move.", color: UIColor(red: 1.0, green: 0.72, blue: 0.46, alpha: 1.0))
            } else {
                showMessage("Tap the map to attack-move.", color: UIColor(red: 1.0, green: 0.72, blue: 0.46, alpha: 1.0))
            }
        case .focusHQ:
            clearPendingCommandModes()
            if let hq = entities.values.first(where: { $0.kind == .hq && $0.faction == .player && $0.isAlive }) {
                cameraRig.position = clampCamera(hq.node.position)
            }
            layoutHUD()
            updateHUD()
        case .cycleAI:
            clearPendingCommandModes()
            aiDifficulty = aiDifficulty.next
            layoutHUD()
            updateHUD()
            showMessage("Enemy AI set to \(aiDifficulty.displayName).", color: UIColor(red: 1.0, green: 0.76, blue: 0.55, alpha: 1.0))
        case .setRally:
            clearConstructionPreview()
            pendingConstructionKind = nil
            pendingSupportPower = nil
            isSettingAttackMove = false
            let factories = selectedPlayerRallyFactories()
            guard !factories.isEmpty else {
                isSettingRallyPoint = false
                showMessage("Select a factory or carrier first.", color: .orange)
                updateHUD()
                return
            }
            isSettingRallyPoint = true
            refreshSelection()
            layoutHUD()
            updateHUD()
            showMessage("Tap the map to set rally point.", color: UIColor(red: 0.70, green: 0.95, blue: 1.0, alpha: 1.0))
        case .buildBase:
            clearConstructionPreview()
            isSettingRallyPoint = false
            isSettingAttackMove = false
            pendingSupportPower = nil
            pendingConstructionKind = nextStructureKind()
            structureBuildCursor = (structureBuildCursor + 1) % buildableStructures.count
            selectedIDs.removeAll()
            refreshSelection()
            layoutHUD()
            updateHUD()
            if let pendingConstructionKind {
                showMessage("Place \(pendingConstructionKind.displayName) for $\(pendingConstructionKind.cost).", color: UIColor(red: 0.98, green: 0.84, blue: 0.46, alpha: 1.0))
            }
        case .newSkirmish:
            restartSkirmish()
        default:
            clearConstructionPreview()
            pendingConstructionKind = nil
            isSettingRallyPoint = false
            isSettingAttackMove = false
            if let power = action.supportPower {
                selectSupportPower(power)
                return
            }
            pendingSupportPower = nil
            layoutHUD()
            updateHUD()
            if let kind = action.buildKind {
                queueBuild(kind: kind, faction: .player, showFeedback: true)
            }
        }
    }

    private func clearPendingCommandModes() {
        clearConstructionPreview()
        pendingConstructionKind = nil
        pendingSupportPower = nil
        isSettingRallyPoint = false
        isSettingAttackMove = false
    }

    private func liveControlGroupIDs(for group: Int) -> Set<Int> {
        Set(controlGroups[group, default: []].filter { id in
            guard let entity = entities[id] else { return false }
            return entity.isAlive && entity.faction == .player && !entity.kind.isStructure
        })
    }

    private func controlGroupSubtitle(for group: Int) -> String {
        let count = liveControlGroupIDs(for: group).count
        return count > 0 ? "\(count) units" : "empty"
    }

    private func controlGroupRecallActionKey(for group: Int) -> String {
        "control-group-\(group)-recall"
    }

    private func cancelPendingControlGroupRecall(_ group: Int) {
        removeAction(forKey: controlGroupRecallActionKey(for: group))
        pendingControlGroupRecallTokens[group] = nil
    }

    private func cancelPendingControlGroupRecalls() {
        for group in pendingControlGroupRecallTokens.keys {
            removeAction(forKey: controlGroupRecallActionKey(for: group))
        }
        pendingControlGroupRecallTokens.removeAll()
    }

    private func scheduleRecallControlGroup(_ group: Int) {
        clearPendingCommandModes()
        cancelPendingControlGroupRecall(group)
        nextControlGroupRecallToken += 1
        let token = nextControlGroupRecallToken
        pendingControlGroupRecallTokens[group] = token
        let action = SKAction.sequence([
            .wait(forDuration: controlGroupRecallDelay),
            .run { [weak self] in
                guard let self, self.pendingControlGroupRecallTokens[group] == token else { return }
                self.pendingControlGroupRecallTokens[group] = nil
                self.recallControlGroup(group)
            }
        ])
        run(action, withKey: controlGroupRecallActionKey(for: group))
    }

    private func recallControlGroup(_ group: Int) {
        clearPendingCommandModes()
        let liveIDs = liveControlGroupIDs(for: group)
        controlGroups[group] = liveIDs

        guard !liveIDs.isEmpty else {
            updateHUD()
            showMessage("Group \(group) is empty.", color: .orange)
            return
        }

        selectedIDs = liveIDs
        refreshSelection()
        updateHUD()
        showMessage("Group \(group) selected: \(liveIDs.count) units.", color: UIColor(red: 0.75, green: 0.95, blue: 1.0, alpha: 1.0))
    }

    private func saveControlGroup(_ group: Int) {
        cancelPendingControlGroupRecall(group)
        clearPendingCommandModes()
        let units = selectedMobilePlayerUnits()
        guard !units.isEmpty else {
            updateHUD()
            showMessage("Select mobile units before saving Group \(group).", color: .orange)
            return
        }

        controlGroups[group] = Set(units.map(\.id))
        updateHUD()
        showMessage("Saved \(units.count) units to Group \(group).", color: UIColor(red: 0.75, green: 0.95, blue: 1.0, alpha: 1.0))
    }

    private func handleWorldTap(at point: CGPoint, tapCount: Int = 1) {
        if let pendingSupportPower {
            executeSupportPower(pendingSupportPower, at: point)
            return
        }

        if let pendingConstructionKind {
            placeStructure(kind: pendingConstructionKind, at: point)
            return
        }

        if isSettingRallyPoint {
            let selectedFactories = selectedPlayerRallyFactories()
            if selectedFactories.isEmpty {
                isSettingRallyPoint = false
                showDeniedMarker(at: point, reason: "NO SOURCE")
                showMessage("No factory or carrier selected.", color: .orange)
                updateHUD()
                return
            }
            setRallyPoint(to: point, for: selectedFactories)
            isSettingRallyPoint = false
            layoutHUD()
            updateHUD()
            return
        }

        if isSettingAttackMove {
            let selected = selectedMobilePlayerUnits().filter { $0.kind.damage > 0 }
            if selected.isEmpty {
                isSettingAttackMove = false
                showDeniedMarker(at: point, reason: "NO UNITS")
                showMessage("No combat units selected.", color: .orange)
                updateHUD()
                return
            }
            issueAttackMoveOrder(to: point, units: selected)
            isSettingAttackMove = false
            layoutHUD()
            updateHUD()
            return
        }

        if let tapped = entity(at: point) {
            if tapped.faction == .player {
                if !tapped.kind.isStructure && tapCount >= 2 {
                    selectVisiblePlayerUnits(matching: tapped)
                    return
                }
                selectedIDs = [tapped.id]
                refreshSelection()
                showMessage("Selected \(tapped.kind.displayName).", color: .white)
                return
            }

            let selected = selectedMobilePlayerUnits()
            if !selected.isEmpty && tapped.faction == .enemy {
                let attackers = selected.filter { $0.kind.canAttack(tapped.kind) }
                let guardReleaseWing = carrierGuardReleaseWing(for: attackers)
                var assignedAttackers = 0
                for unit in attackers {
                    unit.holdPosition = nil
                    clearCarrierGuardAnchor(for: unit)
                    unit.attackMoveDestination = nil
                    unit.attackTarget = tapped
                    unit.destination = nil
                    unit.path.removeAll()
                    assignedAttackers += 1
                }
                if assignedAttackers > 0 {
                    showAttackTargetMarker(
                        at: tapped.node.position,
                        footprint: tapped.kind.footprint,
                        label: tapped.kind.shortCode
                    )
                    showMessage("Attack order: \(tapped.kind.displayName).\(carrierGuardReleaseSuffix(for: guardReleaseWing))", color: UIColor(red: 1.0, green: 0.62, blue: 0.35, alpha: 1.0))
                } else {
                    showDeniedMarker(at: tapped.node.position, reason: "NO ATK")
                    showMessage("Selected units cannot attack that target.", color: .orange)
                }
                return
            }
        }

        let selected = selectedMobilePlayerUnits()
        if selected.isEmpty {
            let selectedFactories = selectedPlayerRallyFactories()
            if !selectedFactories.isEmpty {
                setRallyPoint(to: point, for: selectedFactories)
                return
            }
            if !selectedIDs.isEmpty {
                showDeniedMarker(at: point, reason: "NO UNITS")
            }
            selectedIDs.removeAll()
            refreshSelection()
            return
        }

        issueMoveOrder(to: point, units: selected)
    }

    private func updateSupportCooldowns(dt: TimeInterval) {
        for key in Array(supportCooldowns.keys) {
            let remaining = max(0, supportCooldowns[key, default: 0] - dt)
            if remaining > 0 {
                supportCooldowns[key] = remaining
            } else {
                supportCooldowns.removeValue(forKey: key)
            }
        }
        supportRevealTiles = supportRevealTiles.filter { $0.value > lastUpdateTime }
    }

    private func selectSupportPower(_ power: SupportPower) {
        if let issue = supportIssue(for: power, faction: .player) {
            pendingSupportPower = nil
            showMessage(issue, color: .orange)
            updateHUD()
            return
        }

        pendingConstructionKind = nil
        isSettingRallyPoint = false
        pendingSupportPower = power
        selectedIDs.removeAll()
        refreshSelection()
        updateHUD()
        showMessage("Tap map for \(power.displayName).", color: UIColor(red: 0.72, green: 0.92, blue: 1.0, alpha: 1.0))
    }

    private func executeSupportPower(_ power: SupportPower, at point: CGPoint, faction: Faction = .player, showFeedback: Bool = true) {
        guard let tile = tile(at: point) else {
            if showFeedback && faction == .player {
                showDeniedMarker(at: point, reason: "NO MAP")
                showMessage("Target outside battlefield.", color: .orange)
            }
            return
        }
        let targetPoint = tileCenter(tile)

        if let issue = supportIssue(for: power, faction: faction) {
            if faction == .player {
                pendingSupportPower = nil
            }
            if showFeedback && faction == .player {
                showDeniedMarker(at: targetPoint, reason: supportDeniedReason(for: issue))
                showMessage(issue, color: .orange)
                updateHUD()
            }
            return
        }

        if faction == .player && power != .reconSweep && !exploredTiles.contains(tile) {
            if showFeedback {
                showDeniedMarker(at: targetPoint, reason: "NO SCOUT")
            }
            showMessage("Support target must be scouted first.", color: .orange)
            return
        }

        if power.repairAmount > 0 && supportRepairScore(power, at: targetPoint, for: faction) <= 0 {
            if showFeedback && faction == .player {
                showDeniedMarker(at: targetPoint, reason: "NO REPAIR")
                showMessage("No damaged units in repair zone.", color: .orange)
                updateHUD()
            }
            return
        }

        changeMoney(for: faction, by: -power.cost)
        supportCooldowns[SupportPowerKey(faction: faction, power: power)] = power.cooldown
        if faction == .player {
            pendingSupportPower = nil
        }

        switch power {
        case .reconSweep:
            revealSupportTargets(center: targetPoint, radius: power.radius, duration: 8.0, from: faction)
            if faction == .player {
                revealSupportArea(center: targetPoint, radius: power.radius, duration: 8.0)
            }
            showSupportPowerEffect(power, at: targetPoint, faction: faction)
            if showFeedback && faction == .player {
                showMessage("Recon sweep active.", color: UIColor(red: 0.70, green: 0.95, blue: 1.0, alpha: 1.0))
            } else if showFeedback && faction == .enemy {
                showMessage("Enemy Recon Sweep detected.", color: UIColor(red: 1.0, green: 0.46, blue: 0.32, alpha: 1.0))
            }
        case .fieldRepair:
            let repairedCount = applySupportRepair(power, at: targetPoint, for: faction)
            if faction == .player {
                revealSupportArea(center: targetPoint, radius: power.radius * 0.55, duration: 1.6)
            }
            showSupportPowerEffect(power, at: targetPoint, faction: faction)
            if showFeedback {
                if faction == .player {
                    showMessage("Field Repair restored \(repairedCount) assets.", color: UIColor(red: 0.52, green: 1.0, blue: 0.78, alpha: 1.0))
                } else {
                    showMessage("Enemy Field Repair deployed.", color: UIColor(red: 1.0, green: 0.62, blue: 0.36, alpha: 1.0))
                }
            }
        case .airStrike, .navalBarrage:
            if faction == .player {
                revealSupportArea(center: targetPoint, radius: power.radius * 0.72, duration: 2.4)
            }
            applySupportDamage(power, at: targetPoint, from: faction)
            showSupportPowerEffect(power, at: targetPoint, faction: faction)
            cullDestroyedEntities()
            updateVictoryState()
            if showFeedback {
                if faction == .player {
                    showMessage("\(power.displayName) delivered.", color: UIColor(red: 1.0, green: 0.76, blue: 0.42, alpha: 1.0))
                } else {
                    showMessage("Enemy \(power.displayName) incoming.", color: UIColor(red: 1.0, green: 0.42, blue: 0.28, alpha: 1.0))
                }
            }
        }

        updateFog(force: true)
        updateHUD()
    }

    private func supportCooldown(for faction: Faction, power: SupportPower) -> TimeInterval {
        supportCooldowns[SupportPowerKey(faction: faction, power: power), default: 0]
    }

    private func supportIssue(for power: SupportPower, faction: Faction) -> String? {
        if supportCooldown(for: faction, power: power) > 0 {
            return "\(power.displayName) cooling down."
        }
        guard money(for: faction) >= power.cost else {
            return "Not enough funds for \(power.displayName)."
        }
        guard hasOperationalSupportAsset(for: power, faction: faction) else {
            switch power {
            case .reconSweep:
                return "Recon requires an operational HQ or Radar Outpost."
            case .fieldRepair:
                return "Field Repair requires HQ or Mechanic."
            case .airStrike:
                return "Air Strike requires Airfield or Carrier."
            case .navalBarrage:
                return "Naval Barrage requires Battleship or Carrier."
            }
        }
        return nil
    }

    private func supportDeniedReason(for issue: String) -> String {
        if issue.contains("funds") {
            return "NO FUNDS"
        }
        if issue.contains("cooling") {
            return "NO READY"
        }
        return "NO ASSET"
    }

    private func hasOperationalSupportAsset(for power: SupportPower, faction: Faction) -> Bool {
        entities.values.contains { entity in
            guard entity.faction == faction, entity.isAlive, entity.isOperational else { return false }
            switch power {
            case .reconSweep:
                return entity.kind == .hq || entity.kind == .radarOutpost
            case .fieldRepair:
                return entity.kind == .hq || entity.kind == .mechanic
            case .airStrike:
                return entity.kind == .airfield || entity.kind == .carrier
            case .navalBarrage:
                return entity.kind == .battleship || entity.kind == .carrier
            }
        }
    }

    private func revealSupportArea(center: CGPoint, radius: CGFloat, duration: TimeInterval) {
        guard let origin = tile(at: center) else { return }
        let tileRadius = max(1, Int(ceil(radius / min(tileWidth, tileHeight))))
        let expiry = lastUpdateTime + duration
        for row in max(0, origin.row - tileRadius)...min(rows - 1, origin.row + tileRadius) {
            for col in max(0, origin.col - tileRadius)...min(cols - 1, origin.col + tileRadius) {
                let tile = TileCoord(row: row, col: col)
                if tileCenter(tile).distance(to: center) <= radius {
                    supportRevealTiles[tile] = max(supportRevealTiles[tile, default: 0], expiry)
                }
            }
        }
    }

    private func revealSupportTargets(center: CGPoint, radius: CGFloat, duration: TimeInterval, from faction: Faction) {
        let expiry = lastUpdateTime + duration
        for entity in entities.values where entity.faction != faction && entity.faction != .neutral && entity.isAlive {
            guard entity.kind == .submarine else { continue }
            guard entity.node.position.distance(to: center) <= radius + entity.kind.footprint * 0.35 else { continue }
            entity.revealedUntil = max(entity.revealedUntil, expiry)
        }
    }

    private func revealSubmarineHitBySupport(_ submarine: GameEntity) {
        guard submarine.kind == .submarine else { return }
        submarine.revealedUntil = max(submarine.revealedUntil, lastUpdateTime + 2.4)
        if submarine.faction == .enemy {
            submarine.node.isHidden = !isKnownToFaction(submarine, observer: .player)
        }
    }

    private func applySupportDamage(_ power: SupportPower, at point: CGPoint, from faction: Faction) {
        guard power.damage > 0 else { return }
        for entity in entities.values where entity.faction != faction && entity.faction != .neutral && entity.isAlive {
            let distance = entity.node.position.distance(to: point)
            guard distance <= power.radius + entity.kind.footprint * 0.35 else { continue }
            let falloff = max(0.42, 1.0 - distance / max(power.radius, 1))
            let structureMultiplier: CGFloat = entity.kind.isStructure ? 0.72 : 1.0
            entity.hp -= power.damage * falloff * structureMultiplier
            updateHealthBar(entity)
            if entity.kind == .submarine {
                revealSubmarineHitBySupport(entity)
            }
            if entity.hp <= 0 {
                explode(at: entity.node.position, scale: entity.kind.isStructure ? 1.35 : 0.9)
            }
        }
    }

    @discardableResult
    private func applySupportRepair(_ power: SupportPower, at point: CGPoint, for faction: Faction) -> Int {
        guard power.repairAmount > 0 else { return 0 }

        var repairedCount = 0
        for entity in entities.values where entity.faction == faction && entity.isAlive && entity.hp < entity.kind.maxHP {
            let distance = entity.node.position.distance(to: point)
            guard distance <= power.radius + entity.kind.footprint * 0.35 else { continue }

            let falloff = max(0.55, 1.0 - distance / max(power.radius, 1))
            let structureMultiplier: CGFloat = entity.kind.isStructure ? 0.82 : 1.0
            let repair = power.repairAmount * falloff * structureMultiplier
            let previousHP = entity.hp
            entity.hp = min(entity.kind.maxHP, entity.hp + repair)
            guard entity.hp > previousHP else { continue }

            repairedCount += 1
            updateHealthBar(entity)
            showRepairSpark(at: entity.node.position)
        }

        return repairedCount
    }

    private func nextStructureKind() -> EntityKind {
        buildableStructures[structureBuildCursor % buildableStructures.count]
    }

    private func updateConstructionPreview(at point: CGPoint) {
        guard let kind = pendingConstructionKind else {
            clearConstructionPreview()
            return
        }

        constructionPreviewNode?.removeFromParent()

        let tile = tile(at: point)
        let position = tile.map(tileCenter) ?? point
        let issue: String?
        if let tile {
            issue = constructionIssue(for: kind, faction: .player, tile: tile, position: position)
                ?? (playerMoney >= kind.cost ? nil : "Need $\(kind.cost).")
        } else {
            issue = "Outside map."
        }
        let isValid = issue == nil
        let color = isValid
            ? UIColor(red: 0.30, green: 1.0, blue: 0.36, alpha: 1.0)
            : UIColor(red: 1.0, green: 0.32, blue: 0.22, alpha: 1.0)

        let preview = SKNode()
        preview.position = position
        preview.zPosition = 430

        let footprint = SKShapeNode(ellipseOf: CGSize(width: max(74, kind.footprint * 1.55), height: max(36, kind.footprint * 0.86)))
        footprint.fillColor = color.withAlphaComponent(0.20)
        footprint.strokeColor = color
        footprint.lineWidth = 3
        preview.addChild(footprint)

        let tileOutline = SKShapeNode(path: diamondPath(width: tileWidth * 0.92, height: tileHeight * 0.92))
        tileOutline.strokeColor = color.withAlphaComponent(0.9)
        tileOutline.fillColor = color.withAlphaComponent(0.08)
        tileOutline.lineWidth = 2
        tileOutline.zPosition = -1
        preview.addChild(tileOutline)

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = isValid ? "BUILD \(kind.shortCode)" : (issue ?? "Blocked")
        label.fontSize = 11
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -kind.footprint * 0.5 - 18)
        preview.addChild(label)

        effectsLayer.addChild(preview)
        constructionPreviewNode = preview
    }

    private func clearConstructionPreview() {
        constructionPreviewNode?.removeFromParent()
        constructionPreviewNode = nil
    }

    private func startConstruction(for entity: GameEntity) {
        guard entity.kind.isStructure else { return }
        entity.buildDuration = max(1.0, entity.kind.buildTime)
        entity.buildProgressRemaining = entity.buildDuration
        updateConstructionIndicator(for: entity)
    }

    private func updateConstruction(dt: TimeInterval) {
        var shouldRefreshPlayerVision = false
        let constructing = entities.values.filter { $0.isAlive && $0.kind.isStructure && !$0.isOperational }
        for entity in constructing {
            entity.buildProgressRemaining = max(0, entity.buildProgressRemaining - dt)
            if entity.buildProgressRemaining <= 0 {
                entity.buildProgressRemaining = 0
                entity.constructionNode.removeAllChildren()
                showConstructionPulse(at: entity.node.position)
                if entity.faction == .player {
                    shouldRefreshPlayerVision = true
                    showMessage("\(entity.kind.displayName) operational.", color: UIColor(red: 0.70, green: 0.95, blue: 0.70, alpha: 1.0))
                }
            } else {
                updateConstructionIndicator(for: entity)
            }
        }

        if shouldRefreshPlayerVision {
            updateFog(force: true)
            refreshSelection()
        }
    }

    private func updateConstructionIndicator(for entity: GameEntity) {
        entity.constructionNode.removeAllChildren()
        guard entity.kind.isStructure && !entity.isOperational else { return }

        let duration = max(entity.buildDuration, 0.1)
        let progress = 1.0 - max(0, min(1, entity.buildProgressRemaining / duration))
        let color = entity.faction == .enemy
            ? UIColor(red: 1.0, green: 0.46, blue: 0.30, alpha: 1.0)
            : UIColor(red: 0.98, green: 0.82, blue: 0.30, alpha: 1.0)
        let width = max(62, entity.kind.footprint * 1.24)
        let y = entity.kind.footprint * 0.52 + 43

        let scaffold = SKShapeNode(ellipseOf: CGSize(width: entity.kind.footprint * 1.35, height: entity.kind.footprint * 0.76))
        scaffold.fillColor = color.withAlphaComponent(0.09)
        scaffold.strokeColor = color.withAlphaComponent(0.82)
        scaffold.lineWidth = 2
        scaffold.zPosition = -1
        entity.constructionNode.addChild(scaffold)

        for index in 0..<3 {
            let brace = SKShapeNode(rectOf: CGSize(width: entity.kind.footprint * 1.08, height: 2), cornerRadius: 1)
            brace.position = CGPoint(x: 0, y: CGFloat(index - 1) * 9)
            brace.fillColor = color.withAlphaComponent(0.72)
            brace.strokeColor = .clear
            brace.zRotation = index % 2 == 0 ? 0.52 : -0.52
            entity.constructionNode.addChild(brace)
        }

        let back = SKShapeNode(rectOf: CGSize(width: width, height: 8), cornerRadius: 2)
        back.position = CGPoint(x: 0, y: y)
        back.fillColor = UIColor.black.withAlphaComponent(0.74)
        back.strokeColor = color.withAlphaComponent(0.76)
        back.lineWidth = 1
        entity.constructionNode.addChild(back)

        let fillWidth = max(2, width * progress)
        let fill = SKShapeNode(rectOf: CGSize(width: fillWidth, height: 5), cornerRadius: 1)
        fill.position = CGPoint(x: -width / 2 + fillWidth / 2, y: y)
        fill.fillColor = color
        fill.strokeColor = .clear
        entity.constructionNode.addChild(fill)

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "BUILD \(Int(progress * 100))%"
        label.fontSize = 8
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: y + 13)
        entity.constructionNode.addChild(label)
    }

    private func placeStructure(kind: EntityKind, at point: CGPoint) {
        guard let tile = tile(at: point) else {
            showDeniedMarker(at: point, reason: "NO BUILD")
            showMessage("Invalid build location.", color: .orange)
            return
        }
        let position = tileCenter(tile)

        if let issue = constructionIssue(for: kind, faction: .player, tile: tile, position: position) {
            showDeniedMarker(at: position, reason: "NO BUILD")
            showMessage(issue, color: .orange)
            return
        }
        guard playerMoney >= kind.cost else {
            showDeniedMarker(at: position, reason: "NO FUNDS")
            showMessage("Not enough funds for \(kind.displayName).", color: .orange)
            return
        }

        changeMoney(for: .player, by: -kind.cost)
        pendingConstructionKind = nil
        clearConstructionPreview()

        if kind == .oilDerrick, let existing = oilDerrick(at: position), existing.faction != .player {
            setFaction(.player, for: existing)
            existing.hp = existing.kind.maxHP
            startConstruction(for: existing)
            updateHealthBar(existing)
            selectedIDs = [existing.id]
            refreshSelection()
            showConstructionPulse(at: existing.node.position)
            layoutHUD()
            updateHUD()
            showMessage("Oil derrick under construction.", color: UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 1.0))
            return
        }

        let structure = addEntity(kind: kind, faction: .player, at: position)
        startConstruction(for: structure)
        selectedIDs = [structure.id]
        refreshSelection()
        showConstructionPulse(at: position)
        updateFog(force: true)
        layoutHUD()
        updateHUD()
        showMessage("\(kind.displayName) under construction.", color: UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 1.0))
    }

    private func constructionIssue(for kind: EntityKind, faction: Faction, tile: TileCoord, position: CGPoint) -> String? {
        guard kind.isStructure else { return "Only structures can be placed." }
        if faction == .player {
            guard isVisible(point: position) else { return "Need vision at build site." }
        }
        guard hasNearbyBuildCoverage(position, faction: faction) else { return "Build within base or captured flag radius." }

        if kind == .oilDerrick {
            guard terrain(at: tile) == .oil else { return "Oil derrick requires an oil field." }
            if let existing = oilDerrick(at: position), existing.faction == faction {
                return "Oil derrick already controlled."
            }
            return nil
        }

        if kind == .shipyard || kind == .sonarBuoy || kind == .coastalBattery {
            guard isCoastal(tile) else { return "\(kind.displayName) must be placed on coast." }
        } else {
            guard isLand(tile) else { return "Structure requires clear land." }
        }

        if isOccupiedForConstruction(position, placing: kind) {
            return "Build site blocked."
        }
        return nil
    }

    private func hasNearbyStructure(_ position: CGPoint, faction: Faction) -> Bool {
        entities.values.contains { entity in
            entity.faction == faction &&
            entity.isAlive &&
            entity.kind.isStructure &&
            entity.isOperational &&
            entity.node.position.distance(to: position) <= structureBuildCoverageRadius
        }
    }

    private func hasNearbyControlledFlag(_ position: CGPoint, faction: Faction) -> Bool {
        controlPoints.contains { point in
            point.faction == faction &&
                point.node.position.distance(to: position) <= controlPointBuildCoverageRadius
        }
    }

    private func hasNearbyBuildCoverage(_ position: CGPoint, faction: Faction) -> Bool {
        hasNearbyStructure(position, faction: faction) ||
            hasNearbyControlledFlag(position, faction: faction)
    }

    private func isOccupiedForConstruction(_ position: CGPoint, placing kind: EntityKind) -> Bool {
        if entities.values.contains(where: { entity in
            guard entity.isAlive else { return false }
            if kind == .oilDerrick && entity.kind == .oilDerrick && entity.node.position.distance(to: position) < 46 {
                return false
            }
            return entity.node.position.distance(to: position) < max(58, entity.kind.footprint * 0.9)
        }) {
            return true
        }
        return controlPoints.contains { point in
            point.node.position.distance(to: position) < controlPointNoBuildRadius
        }
    }

    private func oilDerrick(at position: CGPoint) -> GameEntity? {
        entities.values.first { entity in
            entity.kind == .oilDerrick &&
            entity.isAlive &&
            entity.node.position.distance(to: position) < 46
        }
    }

    private func isCoastal(_ tile: TileCoord) -> Bool {
        guard isLand(tile) else { return false }
        for rowOffset in -1...1 {
            for colOffset in -1...1 {
                if rowOffset == 0 && colOffset == 0 { continue }
                let neighbor = TileCoord(row: tile.row + rowOffset, col: tile.col + colOffset)
                if isValid(neighbor) && terrain(at: neighbor) == .water {
                    return true
                }
            }
        }
        return false
    }

    private func restartSkirmish() {
        skirmishSeed += 1
        cancelPendingControlGroupRecalls()
        nextControlGroupRecallToken = 0
        entities.removeAll()
        selectedIDs.removeAll()
        controlGroups = [1: [], 2: []]
        buildOrders.removeAll()
        enemyCaptureReservations.removeAll()
        enemyRetreatingUnitIDs.removeAll()
        nextEntityID = 1
        playerMoney = 5200
        enemyMoney = 5200
        aiBuildCursor = 0
        lastEnemyAssaultWaveSummary = nil
        lastEnemyAssaultWaveSummaryTime = -100
        pendingConstructionKind = nil
        pendingSupportPower = nil
        structureBuildCursor = 0
        hudPage = .tactical
        supportCooldowns.removeAll()
        supportRevealTiles.removeAll()
        isSettingRallyPoint = false
        isSettingAttackMove = false
        victoryState = nil
        completedMissionStages.removeAll()
        incomeAccumulator = 0
        aiAccumulator = 0
        fogAccumulator = 0
        lastPlayerAttackAlertTime = -100
        lastEnemyDefenseResponseTime = -100
        lastEnemyControlPointDefenseResponseTime = -100
        lastUpdateTime = 0
        exploredTiles.removeAll()
        visibleTiles.removeAll()
        clearConstructionPreview()

        mapNode.removeAllChildren()
        entityLayer.removeAllChildren()
        effectsLayer.removeAllChildren()
        fogLayer.removeAllChildren()
        fogNodes.removeAll()

        buildTerrain()
        drawMap()
        spawnControlPoints()
        spawnInitialForces()
        cameraRig.position = clampCamera(tileCenter(TileCoord(row: 12, col: 14)))
        layoutHUD()
        updateFog(force: true)
        updateHUD()
        showMessage("New skirmish map \(skirmishSeed % 3 + 1) loaded.", color: UIColor(red: 0.88, green: 0.92, blue: 1.0, alpha: 1.0))
    }

    private func selectedMobilePlayerUnits() -> [GameEntity] {
        selectedIDs.compactMap { entities[$0] }.filter { $0.faction == .player && !$0.kind.isStructure && $0.isAlive }
    }

    private func selectedPlayerRallyFactories() -> [GameEntity] {
        selectedIDs.compactMap { entities[$0] }.filter { entity in
            entity.faction == .player &&
            entity.isAlive &&
            entity.kind.supportsRallyPoint
        }
    }

    private func setRallyPoint(to point: CGPoint, for factories: [GameEntity]) {
        for factory in factories {
            let destination = navigablePoint(for: rallyDomain(for: factory.kind), near: point)
            factory.rallyPoint = destination
            updateRallyMarker(for: factory)
            showMoveMarker(at: destination)
        }
        refreshSelection()
        showMessage("Rally point set.", color: UIColor(red: 0.70, green: 0.95, blue: 1.0, alpha: 1.0))
        updateHUD()
    }

    private func rallyDomain(for factoryKind: EntityKind) -> Domain {
        switch factoryKind {
        case .barracks:
            .land
        case .airfield:
            .air
        case .carrier:
            .air
        case .shipyard:
            .naval
        default:
            .land
        }
    }

    private func updateRallyMarker(for factory: GameEntity) {
        factory.rallyNode.removeAllChildren()
        guard let rallyPoint = factory.rallyPoint else { return }

        let localPoint = rallyPoint - factory.node.position
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: localPoint)
        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor(red: 0.25, green: 0.90, blue: 1.0, alpha: 0.72)
        line.lineWidth = 2
        line.glowWidth = 1
        factory.rallyNode.addChild(line)

        let ring = SKShapeNode(ellipseOf: CGSize(width: 28, height: 14))
        ring.position = localPoint
        ring.fillColor = UIColor(red: 0.25, green: 0.90, blue: 1.0, alpha: 0.12)
        ring.strokeColor = UIColor(red: 0.25, green: 0.90, blue: 1.0, alpha: 1.0)
        ring.lineWidth = 2
        factory.rallyNode.addChild(ring)

        let flagPole = SKShapeNode(rectOf: CGSize(width: 3, height: 24), cornerRadius: 1)
        flagPole.position = localPoint + CGPoint(x: 0, y: 15)
        flagPole.fillColor = UIColor(white: 0.92, alpha: 1.0)
        flagPole.strokeColor = .clear
        factory.rallyNode.addChild(flagPole)

        let flag = SKShapeNode(rectOf: CGSize(width: 16, height: 9), cornerRadius: 1)
        flag.position = localPoint + CGPoint(x: 8, y: 23)
        flag.fillColor = UIColor(red: 0.25, green: 0.90, blue: 1.0, alpha: 1.0)
        flag.strokeColor = UIColor.black.withAlphaComponent(0.45)
        flag.lineWidth = 1
        factory.rallyNode.addChild(flag)
    }

    private func issueMoveOrder(to point: CGPoint, units: [GameEntity]) {
        issueFormationMove(to: point, units: units, showMarkers: true, showFeedback: true)
    }

    private func issueAttackMoveOrder(to point: CGPoint, units: [GameEntity]) {
        let combatUnits = units.filter { $0.isAlive && !$0.kind.isStructure && $0.kind.damage > 0 }
        guard !combatUnits.isEmpty else {
            showMessage("Select combat units for attack move.", color: .orange)
            updateHUD()
            return
        }

        issueFormationMove(to: point, units: combatUnits, showMarkers: true, showFeedback: true, attackMove: true)
    }

    private func issueHoldPositionOrder(units: [GameEntity]) {
        let mobileUnits = units.filter { $0.isAlive && !$0.kind.isStructure }
        guard !mobileUnits.isEmpty else {
            showMessage("Select mobile units to hold position.", color: .orange)
            updateHUD()
            return
        }

        let previouslyGuardedWingIDs = Set(mobileUnits.filter { unit in
            unit.faction == .player &&
                (unit.kind == .helicopter || unit.kind == .fighter) &&
                carrierGuardAnchor(for: unit) != nil
        }.map(\.id))
        let center = mobileUnits.reduce(CGPoint.zero) { $0 + $1.node.position } / CGFloat(mobileUnits.count)
        for unit in mobileUnits {
            unit.holdPosition = unit.node.position
            clearCarrierGuardAnchor(for: unit)
            unit.attackMoveDestination = nil
            unit.attackTarget = nil
            unit.destination = nil
            unit.path.removeAll()
        }
        let holdCarriers = mobileUnits.filter { $0.kind == .carrier }
        let guardWingCount = assignCarrierGuardWing(for: holdCarriers)

        refreshSelection()
        showHoldMarker(at: center)
        if guardWingCount > 0 {
            for carrier in holdCarriers {
                let guardWing = boundCarrierGuardWing(for: carrier)
                guard !guardWing.isEmpty else { continue }
                let compositionSuffix = carrierAirWingCompositionSuffix(for: guardWing)
                let label = compositionSuffix.isEmpty ? "CV GUARD" : "GW\(compositionSuffix)"
                showCarrierDeckPulse(at: carrier.node.position, faction: carrier.faction, label: label)
            }
        }
        updateHUD()
        let guardWingSuffix: String
        if !holdCarriers.isEmpty {
            var seenWingIDs = Set<Int>()
            let guardWing = holdCarriers.flatMap { boundCarrierGuardWing(for: $0) }.filter { seenWingIDs.insert($0.id).inserted }
            let compositionSuffix = carrierAirWingCompositionSuffix(for: guardWing)
            let requiredWingCount = holdCarriers.count * carrierGuardWingRequirement
            let boundWingCount = min(guardWing.count, requiredWingCount)
            let missingWingCount = max(0, requiredWingCount - boundWingCount)
            let missingSuffix = missingWingCount > 0 ? " Need \(missingWingCount)" : ""
            guardWingSuffix = " Guard wing \(boundWingCount)\(compositionSuffix)\(missingSuffix)."
        } else {
            guardWingSuffix = ""
        }
        let guardReleaseWing = previouslyGuardedWingIDs.compactMap { id -> GameEntity? in
            guard let unit = entities[id], carrierGuardAnchor(for: unit) == nil else { return nil }
            return unit
        }
        showMessage("Hold position: \(mobileUnits.count) units guarding.\(guardWingSuffix)\(carrierGuardReleaseSuffix(for: guardReleaseWing))", color: UIColor(red: 0.78, green: 1.0, blue: 0.58, alpha: 1.0))
    }

    private func carrierGuardReleaseWing(for units: [GameEntity]) -> [GameEntity] {
        units.filter { unit in
            unit.faction == .player &&
                unit.isAlive &&
                (unit.kind == .helicopter || unit.kind == .fighter) &&
                carrierGuardAnchor(for: unit) != nil
        }
    }

    private func carrierGuardReleaseSuffix(for wing: [GameEntity]) -> String {
        guard !wing.isEmpty else { return "" }
        let compositionSuffix = carrierAirWingCompositionSuffix(for: wing)
        return " CV guard released \(wing.count)\(compositionSuffix)."
    }

    private func assignCarrierGuardWing(for carriers: [GameEntity]) -> Int {
        var assignedWingIDs = Set<Int>()
        for carrier in carriers where carrier.faction == .player && carrier.isAlive {
            let candidates = nearbyCarrierAirWing(for: carrier)
                .filter { !assignedWingIDs.contains($0.id) }
                .sorted { left, right in
                    let leftDistance = left.node.position.distance(to: carrier.node.position)
                    let rightDistance = right.node.position.distance(to: carrier.node.position)
                    if leftDistance == rightDistance {
                        return left.id < right.id
                    }
                    return leftDistance < rightDistance
                }
            for wing in candidates.prefix(carrierGuardWingRequirement) {
                wing.holdPosition = wing.node.position
                wing.guardAnchorCarrierID = carrier.id
                wing.attackMoveDestination = nil
                wing.attackTarget = nil
                wing.destination = nil
                wing.path.removeAll()
                assignedWingIDs.insert(wing.id)
            }
        }
        return assignedWingIDs.count
    }

    private func clearCarrierGuardAnchor(for unit: GameEntity) {
        guard unit.kind == .helicopter || unit.kind == .fighter else { return }
        unit.guardAnchorCarrierID = nil
    }

    private func updateCarrierGuardStation(for wing: GameEntity) {
        guard wing.kind == .helicopter || wing.kind == .fighter,
              wing.guardAnchorCarrierID != nil
        else { return }

        guard let carrier = carrierGuardAnchor(for: wing) else {
            clearCarrierGuardAnchor(for: wing)
            return
        }

        let station = carrierGuardStationPoint(for: wing, carrier: carrier)
        if (wing.holdPosition?.distance(to: station) ?? CGFloat.greatestFiniteMagnitude) > carrierGuardStationReanchorTolerance {
            wing.holdPosition = station
        }
    }

    private func carrierGuardStationPoint(for wing: GameEntity, carrier: GameEntity) -> CGPoint {
        let slot = wing.id % 6
        let baseAngle = CGFloat(slot) * (.pi / 3)
        let phase: CGFloat = wing.kind == .fighter ? .pi / 6 : 0
        let radius: CGFloat = wing.kind == .fighter ? 190 : 150
        return carrier.node.position + CGPoint(
            x: cos(baseAngle + phase) * radius,
            y: sin(baseAngle + phase) * radius * 0.62
        )
    }

    private func carrierGuardAnchor(for wing: GameEntity) -> GameEntity? {
        guard (wing.kind == .helicopter || wing.kind == .fighter),
              let carrierID = wing.guardAnchorCarrierID,
              let carrier = entities[carrierID],
              carrier.kind == .carrier,
              carrier.isAlive,
              carrier.faction == wing.faction,
              carrier.holdPosition != nil
        else { return nil }
        return carrier
    }

    private func carrierGuardPriorityTarget(for wing: GameEntity) -> GameEntity? {
        guard let carrier = carrierGuardAnchor(for: wing),
              let holdPosition = wing.holdPosition
        else { return nil }

        return entities.values
            .filter { target in
                isCarrierGuardContact(target, for: wing, carrier: carrier, holdPosition: holdPosition)
            }
            .min { left, right in
                let leftPriority = carrierGuardTargetPriority(for: wing, target: left)
                let rightPriority = carrierGuardTargetPriority(for: wing, target: right)
                if leftPriority == rightPriority {
                    let leftDistance = left.node.position.distance(to: carrier.node.position)
                    let rightDistance = right.node.position.distance(to: carrier.node.position)
                    if abs(leftDistance - rightDistance) < 0.5 {
                        return left.id < right.id
                    }
                    return leftDistance < rightDistance
                }
                return leftPriority < rightPriority
            }
    }

    private func isCarrierGuardContact(_ target: GameEntity, for wing: GameEntity, carrier: GameEntity, holdPosition: CGPoint) -> Bool {
        target.isAlive &&
            target.faction != wing.faction &&
            target.faction != .neutral &&
            wing.kind.canAttack(target.kind) &&
            target.node.position.distance(to: carrier.node.position) <= carrierGuardThreatRadius + target.kind.footprint * 0.35 &&
            target.node.position.distance(to: holdPosition) <= holdEngagementRadius + target.kind.footprint * 0.35 &&
            isKnownToFaction(target, observer: wing.faction)
    }

    private func carrierGuardTargetPriority(for wing: GameEntity, target: GameEntity) -> Int {
        if wing.kind == .fighter && target.kind.domain == .air {
            return 0
        }
        if wing.kind == .helicopter && target.kind == .submarine {
            return 0
        }
        if wing.kind == .helicopter && target.kind.domain == .naval {
            return 1
        }
        return 2
    }

    private func issueFormationMove(to point: CGPoint, units: [GameEntity], showMarkers: Bool, showFeedback: Bool, attackMove: Bool = false) {
        let mobileUnits = units.filter { $0.isAlive && !$0.kind.isStructure }
        guard !mobileUnits.isEmpty else { return }

        let guardReleaseWing = carrierGuardReleaseWing(for: mobileUnits)
        var markerPoints: [CGPoint] = []
        var activeGroups = 0
        for domain in [Domain.land, .air, .naval] {
            let group = mobileUnits.filter { $0.kind.domain == domain }
            guard !group.isEmpty else { continue }

            activeGroups += 1
            let anchor = navigablePoint(for: domain, near: point)
            let ordered = group.sorted { left, right in
                let leftPriority = formationPriority(for: left.kind)
                let rightPriority = formationPriority(for: right.kind)
                if leftPriority == rightPriority {
                    return left.id < right.id
                }
                return leftPriority < rightPriority
            }
            let facing = formationFacing(for: ordered, toward: anchor)
            let offsets = formationOffsets(count: ordered.count, domain: domain, facing: facing)
            for (index, unit) in ordered.enumerated() {
                let unitDestination = navigablePoint(for: domain, near: anchor + offsets[index])
                unit.holdPosition = nil
                clearCarrierGuardAnchor(for: unit)
                unit.attackTarget = nil
                unit.attackMoveDestination = attackMove ? unitDestination : nil
                setDestination(for: unit, near: unitDestination)
            }

            if showMarkers && markerPoints.allSatisfy({ $0.distance(to: anchor) > 34 }) {
                markerPoints.append(anchor)
            }
        }

        if showMarkers {
            for markerPoint in markerPoints {
                if attackMove {
                    showAttackMoveMarker(at: markerPoint)
                } else {
                    showMoveMarker(at: markerPoint)
                }
            }
        }
        if showFeedback {
            let text: String
            if attackMove {
                text = activeGroups > 1 ? "Attack move: combined groups advancing." : "Attack move issued."
            } else {
                text = activeGroups > 1 ? "Formation move: land, air, and naval groups." : "Move order issued."
            }
            showMessage("\(text)\(carrierGuardReleaseSuffix(for: guardReleaseWing))", color: attackMove
                ? UIColor(red: 1.0, green: 0.72, blue: 0.46, alpha: 1.0)
                : UIColor(red: 0.80, green: 0.95, blue: 0.80, alpha: 1.0))
        }
    }

    private func formationPriority(for kind: EntityKind) -> Int {
        switch kind {
        case .humvee, .aaTruck, .fighter, .submarine:
            return 0
        case .tank, .helicopter, .battleship:
            return 1
        case .mechanic:
            return 2
        case .artillery, .carrier:
            return 3
        default:
            return 4
        }
    }

    private func formationFacing(for units: [GameEntity], toward anchor: CGPoint) -> CGPoint {
        let center = units.reduce(CGPoint.zero) { $0 + $1.node.position } / CGFloat(max(1, units.count))
        let vector = anchor - center
        if vector.length > 0.001 {
            return vector.normalized
        }
        return CGPoint(x: 1, y: 0)
    }

    private func formationOffsets(count: Int, domain: Domain, facing: CGPoint) -> [CGPoint] {
        guard count > 1 else { return [.zero] }
        let columns = Int(ceil(sqrt(Double(count))))
        let spacing: CGFloat
        switch domain {
        case .land:
            spacing = 40
        case .air:
            spacing = airFormationSpacing
        case .naval:
            spacing = 70
        case .structure:
            spacing = 40
        }
        let side = CGPoint(x: -facing.y, y: facing.x)
        return (0..<count).map { index in
            let row = index / columns
            let col = index % columns
            let rowCount = min(columns, count - row * columns)
            let sideIndex = CGFloat(col) - CGFloat(rowCount - 1) / 2
            let backDistance = CGFloat(row) * spacing * 0.72
            return side * (sideIndex * spacing) + facing * (-backDistance)
        }
    }

    private func entity(at point: CGPoint) -> GameEntity? {
        let candidates = entities.values.filter { entity in
            guard entity.isAlive else { return false }
            if entity.faction == .enemy && !isKnownToFaction(entity, observer: .player) { return false }
            return entity.node.position.distance(to: point) <= entity.kind.footprint * 0.95
        }
        return candidates.min { $0.node.position.distance(to: point) < $1.node.position.distance(to: point) }
    }

    @discardableResult
    private func queueBuild(kind: EntityKind, faction: Faction, showFeedback: Bool) -> Bool {
        guard let factoryKind = kind.requiredFactory else { return false }
        guard let source = productionSource(for: kind, faction: faction) else {
            if showFeedback {
                if kind.domain == .air {
                    showMessage("Requires Airfield or Carrier.", color: .orange)
                } else {
                    showMessage("Requires \(factoryKind.displayName).", color: .orange)
                }
            }
            return false
        }

        guard money(for: faction) >= kind.cost else {
            if showFeedback {
                showMessage("Not enough funds for \(kind.displayName).", color: .orange)
            }
            return false
        }

        changeMoney(for: faction, by: -kind.cost)
        buildOrders.append(BuildOrder(kind: kind, faction: faction, sourceID: source.id, duration: kind.buildTime, remaining: kind.buildTime))
        updateProductionIndicators()
        if showFeedback {
            showMessage("Building \(kind.displayName).", color: UIColor(red: 0.95, green: 0.82, blue: 0.48, alpha: 1.0))
        }
        return true
    }

    private func productionSource(for kind: EntityKind, faction: Faction) -> GameEntity? {
        guard kind.requiredFactory != nil else { return nil }
        let candidates = entities.values.filter { entity in
            entity.kind.canProduce(kind) &&
            entity.faction == faction &&
            entity.isAlive &&
            entity.isOperational
        }
        guard !candidates.isEmpty else { return nil }

        if faction == .player,
           let selectedFactory = candidates
            .filter({ selectedIDs.contains($0.id) })
            .min(by: { queueDepth(for: $0.id) < queueDepth(for: $1.id) }) {
            return selectedFactory
        }

        return candidates.min {
            let leftDepth = queueDepth(for: $0.id)
            let rightDepth = queueDepth(for: $1.id)
            if leftDepth == rightDepth {
                return $0.id < $1.id
            }
            return leftDepth < rightDepth
        }
    }

    private func canQueueBuild(kind: EntityKind, faction: Faction) -> Bool {
        kind.requiredFactory != nil &&
        productionSource(for: kind, faction: faction) != nil &&
        money(for: faction) >= kind.cost
    }

    private func queueDepth(for sourceID: Int) -> Int {
        buildOrders.filter { $0.sourceID == sourceID }.count
    }

    private func updateBuildOrders(dt: TimeInterval) {
        guard !buildOrders.isEmpty else {
            updateProductionIndicators()
            return
        }
        var activeSources = Set<Int>()
        for index in buildOrders.indices {
            let sourceID = buildOrders[index].sourceID
            guard !activeSources.contains(sourceID),
                  let source = entities[sourceID],
                  source.isAlive,
                  source.isOperational
            else { continue }

            buildOrders[index].remaining -= dt
            activeSources.insert(sourceID)
        }

        let ready = buildOrders.filter { $0.remaining <= 0 }
        buildOrders.removeAll { $0.remaining <= 0 }

        for order in ready {
            guard let source = entities[order.sourceID], source.isAlive, source.isOperational else { continue }
            let spawnPoint = spawnPoint(for: order.kind, from: source)
            let entity = addEntity(kind: order.kind, faction: order.faction, at: spawnPoint)
            if source.kind == .carrier && order.kind.domain == .air {
                showCarrierLaunch(from: source.node.position, to: spawnPoint, faction: source.faction, kind: order.kind)
            }
            if order.faction == .enemy, let target = tacticalTarget(for: entity) {
                entity.attackTarget = target
                setDestination(for: entity, near: attackDestination(for: entity, target: target))
            } else if order.faction == .player, let rallyPoint = source.rallyPoint {
                setDestination(for: entity, near: rallyPoint)
            }
            if order.faction == .player {
                showMessage("\(order.kind.displayName) ready.", color: UIColor(red: 0.70, green: 0.95, blue: 0.70, alpha: 1.0))
            }
            showProductionReady(at: source.node.position, faction: order.faction, kind: order.kind)
        }
        updateProductionIndicators()
    }

    private func updateProductionIndicators() {
        for entity in entities.values {
            entity.productionNode.removeAllChildren()
        }

        var activeOrders: [Int: BuildOrder] = [:]
        var queuedCounts: [Int: Int] = [:]
        for order in buildOrders {
            if activeOrders[order.sourceID] == nil {
                activeOrders[order.sourceID] = order
            }
            queuedCounts[order.sourceID, default: 0] += 1
        }

        for (sourceID, order) in activeOrders {
            guard let source = entities[sourceID], source.isAlive else { continue }
            addProductionIndicator(to: source, order: order, queuedCount: queuedCounts[sourceID, default: 1])
        }
    }

    private func addProductionIndicator(to source: GameEntity, order: BuildOrder, queuedCount: Int) {
        let width = max(58, source.kind.footprint * 1.18)
        let y = source.kind.footprint * 0.52 + 29
        let progress = 1.0 - max(0, min(1, order.remaining / max(order.duration, 0.1)))
        let color = source.faction == .enemy
            ? UIColor(red: 1.0, green: 0.42, blue: 0.30, alpha: 1.0)
            : UIColor(red: 0.25, green: 0.95, blue: 1.0, alpha: 1.0)

        let back = SKShapeNode(rectOf: CGSize(width: width, height: 8), cornerRadius: 2)
        back.position = CGPoint(x: 0, y: y)
        back.fillColor = UIColor.black.withAlphaComponent(0.72)
        back.strokeColor = color.withAlphaComponent(0.65)
        back.lineWidth = 1
        source.productionNode.addChild(back)

        let fillWidth = max(2, width * progress)
        let fill = SKShapeNode(rectOf: CGSize(width: fillWidth, height: 5), cornerRadius: 1)
        fill.position = CGPoint(x: -width / 2 + fillWidth / 2, y: y)
        fill.fillColor = color
        fill.strokeColor = .clear
        source.productionNode.addChild(fill)

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = queuedCount > 1 ? "\(order.kind.shortCode) x\(queuedCount)" : order.kind.shortCode
        label.fontSize = 8
        label.fontColor = UIColor.white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: y + 13)
        source.productionNode.addChild(label)
    }

    private func spawnPoint(for kind: EntityKind, from source: GameEntity) -> CGPoint {
        switch kind.domain {
        case .naval:
            return nearestPoint(matching: { self.terrain(at: $0) == .water }, near: source.node.position) ?? source.node.position + CGPoint(x: 120, y: -20)
        case .land:
            return nearestPoint(matching: { self.isLand($0) }, near: source.node.position) ?? source.node.position + CGPoint(x: 70, y: -25)
        case .air:
            if source.kind == .carrier {
                return source.node.position + CGPoint(x: 0, y: 54)
            }
            return source.node.position + CGPoint(x: 0, y: 78)
        case .structure:
            return source.node.position
        }
    }

    private func nearestPoint(matching predicate: (TileCoord) -> Bool, near point: CGPoint) -> CGPoint? {
        guard let origin = tile(at: point) else { return nil }
        var best: (tile: TileCoord, distance: Int)?
        for radius in 0...8 {
            for row in max(0, origin.row - radius)...min(rows - 1, origin.row + radius) {
                for col in max(0, origin.col - radius)...min(cols - 1, origin.col + radius) {
                    let tile = TileCoord(row: row, col: col)
                    guard predicate(tile) else { continue }
                    let distance = abs(tile.row - origin.row) + abs(tile.col - origin.col)
                    if best == nil || distance < best!.distance {
                        best = (tile, distance)
                    }
                }
            }
            if let best {
                return tileCenter(best.tile)
            }
        }
        return nil
    }

    private func updateEconomy(dt: TimeInterval) {
        incomeAccumulator += dt
        guard incomeAccumulator >= 1.0 else { return }
        incomeAccumulator -= 1.0
        changeMoney(for: .player, by: incomePerTick(for: .player))
        changeMoney(for: .enemy, by: incomePerTick(for: .enemy) + aiDifficulty.incomeBonus)
    }

    private func incomePerTick(for faction: Faction) -> Int {
        let hqIncome = entities.values.contains { $0.kind == .hq && $0.faction == faction && $0.isAlive && $0.isOperational } ? 70 : 0
        return hqIncome + oilCount(for: faction) * 145 + controlPointCount(for: faction) * 95
    }

    private func oilCount(for faction: Faction) -> Int {
        entities.values.filter { $0.kind == .oilDerrick && $0.faction == faction && $0.isAlive && $0.isOperational }.count
    }

    private func controlPointCount(for faction: Faction) -> Int {
        controlPoints.filter { $0.faction == faction }.count
    }

    private func coastalAssetCount(for faction: Faction) -> Int {
        let assets = coastalAssetBreakdown(for: faction)
        return assets.shipyards + assets.sonarBuoys + assets.coastalBatteries
    }

    private func coastalAssetBreakdown(for faction: Faction) -> (shipyards: Int, sonarBuoys: Int, coastalBatteries: Int) {
        let operationalAssets = entities.values.filter { entity in
            entity.faction == faction && entity.isAlive && entity.isOperational
        }
        return (
            operationalAssets.filter { $0.kind == .shipyard }.count,
            operationalAssets.filter { $0.kind == .sonarBuoy }.count,
            operationalAssets.filter { $0.kind == .coastalBattery }.count
        )
    }

    private func updateCapture(dt: TimeInterval) {
        let derricks = entities.values.filter { $0.kind == .oilDerrick && $0.isAlive }
        for derrick in derricks {
            let nearbyPlayer = captureUnit(near: derrick, faction: .player)
            let nearbyEnemy = captureUnit(near: derrick, faction: .enemy)
            var capturingFaction: Faction?

            if let nearbyPlayer, nearbyEnemy == nil, derrick.faction != .player {
                capturingFaction = .player
                derrick.captureProgress += CGFloat(dt) * captureRate(for: nearbyPlayer)
                if derrick.captureProgress >= 3.0 {
                    setFaction(.player, for: derrick)
                    derrick.captureProgress = 0
                    showMessage("Oil derrick captured.", color: UIColor(red: 0.70, green: 0.95, blue: 0.70, alpha: 1.0))
                }
            } else if let nearbyEnemy, nearbyPlayer == nil, derrick.faction != .enemy {
                capturingFaction = .enemy
                derrick.captureProgress += CGFloat(dt) * captureRate(for: nearbyEnemy)
                if derrick.captureProgress >= 3.0 {
                    setFaction(.enemy, for: derrick)
                    derrick.captureProgress = 0
                }
            } else {
                derrick.captureProgress = max(0, derrick.captureProgress - CGFloat(dt))
            }
            updateCaptureIndicator(for: derrick, capturingFaction: capturingFaction)
        }
    }

    private func captureUnit(near derrick: GameEntity, faction: Faction) -> GameEntity? {
        entities.values.first { unit in
            unit.faction == faction &&
            unit.isAlive &&
            !unit.kind.isStructure &&
            unit.kind.domain != .air &&
            unit.node.position.distance(to: derrick.node.position) < 78
        }
    }

    private func captureRate(for unit: GameEntity) -> CGFloat {
        switch unit.kind {
        case .mechanic:
            return 1.4
        case .humvee:
            return 1.05
        default:
            return 0.75
        }
    }

    private func updateCaptureIndicator(for derrick: GameEntity, capturingFaction: Faction?) {
        derrick.captureNode.removeAllChildren()
        guard let capturingFaction, derrick.captureProgress > 0 else { return }

        let width = max(48, derrick.kind.footprint * 1.16)
        let y = derrick.kind.footprint * 0.52 + 31
        let progress = max(0, min(1, derrick.captureProgress / 3.0))
        let fillColor = capturingFaction == .enemy
            ? UIColor(red: 1.0, green: 0.38, blue: 0.25, alpha: 1.0)
            : UIColor(red: 0.24, green: 0.88, blue: 1.0, alpha: 1.0)

        let back = SKShapeNode(rectOf: CGSize(width: width, height: 7), cornerRadius: 2)
        back.position = CGPoint(x: 0, y: y)
        back.fillColor = UIColor.black.withAlphaComponent(0.70)
        back.strokeColor = fillColor.withAlphaComponent(0.7)
        back.lineWidth = 1
        derrick.captureNode.addChild(back)

        let fillWidth = max(2, width * progress)
        let fill = SKShapeNode(rectOf: CGSize(width: fillWidth, height: 4), cornerRadius: 1)
        fill.position = CGPoint(x: -width / 2 + fillWidth / 2, y: y)
        fill.fillColor = fillColor
        fill.strokeColor = .clear
        derrick.captureNode.addChild(fill)

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "CAP \(Int(progress * 100))%"
        label.fontSize = 8
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: y + 12)
        derrick.captureNode.addChild(label)
    }

    private func updateControlPointCapture(dt: TimeInterval) {
        for point in controlPoints {
            let nearbyPlayer = controlPointCaptureUnit(near: point, faction: .player)
            let nearbyEnemy = controlPointCaptureUnit(near: point, faction: .enemy)

            if let nearbyPlayer, nearbyEnemy == nil, point.faction != .player {
                if point.faction == .enemy {
                    triggerEnemyControlPointDefenseIfNeeded(point: point, intruder: nearbyPlayer)
                }
                point.capturingFaction = .player
                point.captureProgress += CGFloat(dt) * captureRate(for: nearbyPlayer)
                if point.captureProgress >= 4.0 {
                    setControlPointFaction(.player, for: point)
                    showMessage("\(point.name) flag captured. +$\(controlPointCaptureBonus)", color: UIColor(red: 0.70, green: 0.95, blue: 1.0, alpha: 1.0))
                }
            } else if let nearbyEnemy, nearbyPlayer == nil, point.faction != .enemy {
                point.capturingFaction = .enemy
                point.captureProgress += CGFloat(dt) * captureRate(for: nearbyEnemy)
                if point.captureProgress >= 4.0 {
                    setControlPointFaction(.enemy, for: point)
                }
            } else {
                point.captureProgress = max(0, point.captureProgress - CGFloat(dt) * 0.75)
                if point.captureProgress <= 0 {
                    point.capturingFaction = nil
                }
            }

            updateControlPointVisual(point)
        }
    }

    private func controlPointCaptureUnit(near point: BattlefieldControlPoint, faction: Faction) -> GameEntity? {
        entities.values.first { unit in
            unit.faction == faction &&
            unit.isAlive &&
            !unit.kind.isStructure &&
            unit.kind.domain != .air &&
            unit.node.position.distance(to: point.node.position) < 92
        }
    }

    private func setControlPointFaction(_ faction: Faction, for point: BattlefieldControlPoint) {
        let previousFaction = point.faction
        point.faction = faction
        point.capturingFaction = nil
        point.captureProgress = 0
        if previousFaction != faction {
            changeMoney(for: faction, by: controlPointCaptureBonus)
        }
        updateControlPointVisual(point)
        if previousFaction == .player || faction == .player {
            updateFog(force: true)
        }
    }

    private func setFaction(_ faction: Faction, for entity: GameEntity) {
        entity.faction = faction
        entity.teamFlag.fillColor = faction.color
        entity.label.fontColor = faction == .enemy ? UIColor(red: 1.0, green: 0.80, blue: 0.75, alpha: 1.0) : .white
        entity.captureNode.removeAllChildren()
    }

    private func updateRepair(dt: TimeInterval) {
        let mechanics = entities.values.filter { $0.kind == .mechanic && $0.isAlive }
        for mechanic in mechanics {
            guard let target = entities.values
                .filter({ $0.faction == mechanic.faction && $0.isAlive && $0.id != mechanic.id && $0.hp < $0.kind.maxHP })
                .min(by: { $0.node.position.distance(to: mechanic.node.position) < $1.node.position.distance(to: mechanic.node.position) }),
                target.node.position.distance(to: mechanic.node.position) < mechanicRepairRange
            else { continue }

            target.hp = min(target.kind.maxHP, target.hp + CGFloat(dt) * mechanicRepairPerSecond)
            updateHealthBar(target)
            if Int.random(in: 0...20) == 0 {
                showRepairSpark(at: target.node.position)
            }
        }
    }

    private func updateMovement(dt: TimeInterval) {
        for entity in entities.values where entity.isAlive && !entity.kind.isStructure {
            updateCarrierGuardStation(for: entity)

            if entity.attackTarget == nil, let attackMoveDestination = entity.attackMoveDestination, entity.destination == nil {
                let arrivalRadius = max(18, entity.kind.footprint * 0.45)
                if entity.node.position.distance(to: attackMoveDestination) <= arrivalRadius {
                    entity.attackMoveDestination = nil
                    entity.destination = nil
                    entity.path.removeAll()
                } else {
                    setDestination(for: entity, near: attackMoveDestination)
                }
            }

            if let attackTarget = entity.attackTarget, attackTarget.isAlive {
                if let holdPosition = entity.holdPosition,
                   attackTarget.node.position.distance(to: holdPosition) > holdEngagementRadius + attackTarget.kind.footprint * 0.35 {
                    entity.attackTarget = nil
                    if entity.node.position.distance(to: holdPosition) > holdReturnTolerance {
                        setDestination(for: entity, near: holdPosition)
                    }
                }
            }

            if let attackTarget = entity.attackTarget, attackTarget.isAlive {
                let distance = entity.node.position.distance(to: attackTarget.node.position)
                let approachPoint = attackDestination(for: entity, target: attackTarget)
                if entity.kind.domain == .air {
                    if entity.node.position.distance(to: approachPoint) > 18 {
                        setDestination(for: entity, near: approachPoint)
                    } else {
                        entity.destination = nil
                        entity.path.removeAll()
                    }
                } else if distance > entity.kind.attackRange * 0.82 {
                    setDestination(for: entity, near: approachPoint)
                } else {
                    entity.destination = nil
                    entity.path.removeAll()
                }
            } else if let holdPosition = entity.holdPosition,
                      entity.destination == nil,
                      entity.node.position.distance(to: holdPosition) > holdReturnTolerance {
                setDestination(for: entity, near: holdPosition)
            }

            guard let destination = entity.destination else {
                animateIdle(entity, dt: dt)
                continue
            }

            let current = entity.node.position
            let vector = destination - current
            let distance = vector.length
            if distance < 4 {
                advancePath(for: entity)
                continue
            }

            let step = min(distance, movementSpeed(for: entity) * CGFloat(dt))
            let desiredDirection = vector.normalized
            let direction = separatedMovementDirection(for: entity, desired: desiredDirection)
            entity.node.position = current + direction * step
            entity.node.zPosition = entityZPosition(entity)
            if abs(direction.x) > 0.01 {
                entity.node.xScale = direction.x < 0 ? -1 : 1
            }
            updateNavalWake(for: entity, direction: direction)
            updateAirShadow(for: entity, direction: direction)
        }
    }

    private func separatedMovementDirection(for entity: GameEntity, desired: CGPoint) -> CGPoint {
        guard entity.kind.domain == .air else { return desired }

        var separation = CGPoint.zero
        for neighbor in entities.values where
            neighbor.id != entity.id &&
            neighbor.isAlive &&
            neighbor.faction == entity.faction &&
            neighbor.kind.domain == .air {
            let delta = entity.node.position - neighbor.node.position
            let distance = delta.length
            guard distance < airSeparationRadius else { continue }

            if distance < 0.5 {
                let sign: CGFloat = entity.id < neighbor.id ? -1 : 1
                separation = separation + CGPoint(x: sign, y: neighbor.id.isMultiple(of: 2) ? 0.45 : -0.45)
            } else {
                let pressure = 1 - distance / airSeparationRadius
                separation = separation + delta.normalized * pressure
            }
        }

        guard separation.length > 0.001 else { return desired }
        let candidate = (desired + separation.normalized * airSeparationWeight).normalized
        let forwardDot = candidate.x * desired.x + candidate.y * desired.y
        return forwardDot >= 0.30 ? candidate : desired
    }

    private func updateNavalWake(for entity: GameEntity, direction: CGPoint) {
        guard entity.kind.domain == .naval else { return }

        let horizontalScale = entity.node.xScale == 0 ? 1 : entity.node.xScale
        let localWakeDirection = CGPoint(x: -direction.x / horizontalScale, y: -direction.y)
        entity.navalWakeNode.zRotation = atan2(localWakeDirection.y, localWakeDirection.x)
        entity.navalWakeNode.alpha = 0.82 + sin(CGFloat(lastUpdateTime) * 7 + CGFloat(entity.id)) * 0.10
        entity.navalWakeNode.isHidden = false
    }

    private func updateAirShadow(for entity: GameEntity, direction: CGPoint) {
        guard entity.kind.domain == .air else { return }
        let horizontalScale = entity.node.xScale == 0 ? 1 : entity.node.xScale
        entity.airShadowNode.position = CGPoint(
            x: -direction.x * 11 / horizontalScale,
            y: -12 - direction.y * 6
        )
        entity.airShadowNode.alpha = 0.88 + sin(CGFloat(lastUpdateTime) * 4 + CGFloat(entity.id)) * 0.08
    }

    private func movementSpeed(for entity: GameEntity) -> CGFloat {
        var speed = entity.kind.speed
        guard let tile = tile(at: entity.node.position) else { return speed }

        switch entity.kind.domain {
        case .land:
            switch terrain(at: tile) {
            case .road:
                speed *= 1.28
            case .oil:
                speed *= 0.90
            default:
                break
            }
        case .air, .naval, .structure:
            break
        }

        return speed
    }

    private func animateIdle(_ entity: GameEntity, dt: TimeInterval) {
        entity.navalWakeNode.isHidden = true
        if entity.kind.domain == .air {
            let bob = sin(CGFloat(lastUpdateTime) * 3.4 + CGFloat(entity.id)) * 2.2
            entity.node.position.y += bob * CGFloat(dt)
        }
    }

    private func prepareCICaptureScene() {
        guard isCICaptureMode else { return }
        if ProcessInfo.processInfo.environment["DESERT_CI_CAMERA_FOCUS"] == "land" {
            prepareCILandCaptureScene()
            return
        }
        if ProcessInfo.processInfo.environment["DESERT_CI_CAMERA_FOCUS"] == "air" {
            prepareCIAirCaptureScene()
            return
        }

        let playerNavy = entities.values
            .filter { $0.faction == .player && $0.kind.domain == .naval && $0.isAlive }
            .sorted { $0.id < $1.id }
        for (index, entity) in playerNavy.enumerated() {
            if entity.kind == .carrier {
                entity.node.position = tileCenter(TileCoord(row: 19, col: 22))
                entity.node.zPosition = entityZPosition(entity)
            }
            let direction = CGPoint(x: -0.94, y: index.isMultiple(of: 2) ? 0.34 : -0.34).normalized
            entity.destination = entity.node.position + direction * 180
            updateNavalWake(for: entity, direction: direction)
        }

        if let battleship = playerNavy.first(where: { $0.kind == .battleship }) {
            showNavalWaterImpact(
                at: battleship.node.position + CGPoint(x: 88, y: 18),
                faction: .player,
                scale: 1.0,
                persistent: true
            )
        }
        if let carrier = playerNavy.first(where: { $0.kind == .carrier }) {
            showNavalWaterImpact(
                at: carrier.node.position + CGPoint(x: 96, y: -14),
                faction: .enemy,
                scale: 1.15,
                persistent: true
            )
        }
    }

    private func prepareCILandCaptureScene() {
        let playerTanks = entities.values
            .filter { $0.faction == .player && $0.kind == .tank && $0.isAlive }
            .sorted { $0.id < $1.id }
        let enemyTanks = entities.values
            .filter { $0.faction == .enemy && $0.kind == .tank && $0.isAlive }
            .sorted { $0.id < $1.id }
        let extraEnemyTank = addEntity(
            kind: .tank,
            faction: .enemy,
            at: tileCenter(TileCoord(row: 15, col: 16))
        )
        let blueAnchor = tileCenter(TileCoord(row: 15, col: 11))
        let redAnchor = tileCenter(TileCoord(row: 15, col: 15))
        let blueOffsets = [CGPoint(x: 0, y: 0), CGPoint(x: -46, y: -62)]
        let redOffsets = [CGPoint(x: 0, y: 0), CGPoint(x: 46, y: 62)]

        for (index, tank) in playerTanks.prefix(2).enumerated() {
            tank.node.position = blueAnchor + blueOffsets[index]
            tank.node.xScale = 1
            tank.node.zPosition = entityZPosition(tank)
            tank.destination = redAnchor
        }
        let captureEnemyTanks = Array(enemyTanks.prefix(1)) + [extraEnemyTank]
        for (index, tank) in captureEnemyTanks.enumerated() {
            tank.node.position = redAnchor + redOffsets[index]
            tank.node.xScale = -1
            tank.node.zPosition = entityZPosition(tank)
            tank.destination = blueAnchor
        }

        selectedIDs = Set(playerTanks.prefix(2).map(\.id))
        updateFog(force: true)
        refreshSelection()
        explode(at: tileCenter(TileCoord(row: 15, col: 13)), scale: 0.72, persistent: true)
    }

    private func prepareCIAirCaptureScene() {
        let playerHelicopter = entities.values.first { $0.faction == .player && $0.kind == .helicopter }
        let enemyHelicopter = entities.values.first { $0.faction == .enemy && $0.kind == .helicopter }

        let playerFighter = addEntity(
            kind: .fighter,
            faction: .player,
            at: tileCenter(TileCoord(row: 15, col: 14))
        )
        let playerFighterTwo = addEntity(
            kind: .fighter,
            faction: .player,
            at: tileCenter(TileCoord(row: 15, col: 14))
        )
        let enemyFighter = addEntity(
            kind: .fighter,
            faction: .enemy,
            at: tileCenter(TileCoord(row: 15, col: 18))
        )
        let enemyFighterTwo = addEntity(
            kind: .fighter,
            faction: .enemy,
            at: tileCenter(TileCoord(row: 15, col: 18))
        )
        let enemySAM = addEntity(
            kind: .samSite,
            faction: .enemy,
            at: tileCenter(TileCoord(row: 14, col: 16))
        )
        let enemyAA = addEntity(
            kind: .aaTruck,
            faction: .enemy,
            at: tileCenter(TileCoord(row: 16, col: 17))
        )

        let playerAir = [playerHelicopter, playerFighter, playerFighterTwo].compactMap { $0 }
        let enemyAir = [enemyHelicopter, enemyFighter, enemyFighterTwo].compactMap { $0 }
        let playerFacing = CGPoint(x: 0.96, y: 0.18).normalized
        let enemyFacing = CGPoint(x: -0.96, y: -0.18).normalized
        let playerOffsets = formationOffsets(count: playerAir.count, domain: .air, facing: playerFacing)
        let enemyOffsets = formationOffsets(count: enemyAir.count, domain: .air, facing: enemyFacing)
        let playerAnchor = tileCenter(TileCoord(row: 15, col: 14)) + CGPoint(x: 0, y: 28)
        let enemyAnchor = tileCenter(TileCoord(row: 15, col: 18)) + CGPoint(x: 0, y: 28)

        for (index, aircraft) in playerAir.enumerated() {
            aircraft.node.position = playerAnchor + playerOffsets[index]
            aircraft.node.zPosition = entityZPosition(aircraft)
            aircraft.destination = aircraft.node.position + playerFacing * 180
            aircraft.node.xScale = 1
            updateAirShadow(for: aircraft, direction: playerFacing)
        }
        for (index, aircraft) in enemyAir.enumerated() {
            aircraft.node.position = enemyAnchor + enemyOffsets[index]
            aircraft.node.zPosition = entityZPosition(aircraft)
            aircraft.destination = aircraft.node.position + enemyFacing * 180
            aircraft.node.xScale = -1
            updateAirShadow(for: aircraft, direction: enemyFacing)
        }

        selectedIDs = Set(playerAir.map(\.id))
        if let playerBattleship = entities.values.first(where: { $0.faction == .player && $0.kind == .battleship && $0.isAlive }) {
            selectedIDs.insert(playerBattleship.id)
        }
        // Freeze representative command intents for CI screenshot readability.
        playerFighter.attackTarget = enemyFighter
        playerFighter.destination = nil
        playerFighter.attackMoveDestination = nil
        if let playerHeli = playerAir.first(where: { $0.kind == .helicopter }) {
            playerHeli.attackTarget = nil
            playerHeli.attackMoveDestination = playerHeli.node.position + playerFacing * 210
            playerHeli.destination = nil
            playerHeli.path.removeAll()
        }
        for aircraft in playerAir where aircraft.kind == .fighter && aircraft.id != playerFighter.id {
            // second fighter shares focus-fire target for CI marker evidence
            aircraft.attackTarget = enemyFighter
            aircraft.destination = nil
            aircraft.attackMoveDestination = nil
            aircraft.path.removeAll()
        }
        updateFog(force: true)
        refreshSelection()
        enemySAM.node.zPosition = entityZPosition(enemySAM)
        enemyAA.node.zPosition = entityZPosition(enemyAA)
        showGuidedMissileTrail(
            from: playerFighter.node.position,
            to: enemyFighter.node.position,
            kind: .fighter,
            persistent: true
        )
        showAirMissileImpact(
            at: enemyFighter.node.position + CGPoint(x: -12, y: 4),
            faction: .player,
            persistent: true
        )
        showDamageFloater(
            at: enemyFighter.node.position + CGPoint(x: 16, y: 22),
            amount: 24,
            faction: .player,
            persistent: true
        )
        explode(
            at: enemyFighter.node.position + CGPoint(x: -28, y: -10),
            scale: 0.85,
            persistent: true
        )

        switch ProcessInfo.processInfo.environment["DESERT_CI_COMMAND_MARKER"] {
        case "move":
            showMoveMarker(
                at: playerAnchor + CGPoint(x: -120, y: -150),
                persistent: true
            )
        case "attack-move":
            showAttackMoveMarker(
                at: (playerAnchor + enemyAnchor) * 0.5 + CGPoint(x: 0, y: -150),
                persistent: true
            )
        case "attack-target":
            showAttackTargetMarker(
                at: enemyFighter.node.position,
                footprint: enemyFighter.kind.footprint,
                label: enemyFighter.kind.shortCode,
                persistent: true
            )
        default:
            break
        }
    }

    private func updateCombat(dt: TimeInterval) {
        for entity in entities.values where entity.isAlive && entity.kind.damage > 0 {
            if entity.kind.isStructure && !entity.isOperational {
                entity.attackTarget = nil
                entity.attackTimer = 0
                continue
            }

            entity.attackTimer = max(0, entity.attackTimer - dt)

            if let target = entity.attackTarget, (!target.isAlive || target.faction == entity.faction || !entity.kind.canAttack(target.kind)) {
                entity.attackTarget = nil
                if entity.attackMoveDestination != nil {
                    entity.destination = nil
                    entity.path.removeAll()
                }
            }

            if let target = entity.attackTarget, !isKnownToFaction(target, observer: entity.faction) {
                entity.attackTarget = nil
                if entity.attackMoveDestination != nil {
                    entity.destination = nil
                    entity.path.removeAll()
                }
            }

            if let target = entity.attackTarget,
               let holdPosition = entity.holdPosition,
               target.node.position.distance(to: holdPosition) > holdEngagementRadius + target.kind.footprint * 0.35 {
                entity.attackTarget = nil
            }

            if entity.attackTarget == nil {
                let acquisitionRange: CGFloat
                if entity.holdPosition != nil {
                    acquisitionRange = holdEngagementRadius
                } else if entity.attackMoveDestination != nil {
                    acquisitionRange = attackMoveEngagementRadius
                } else {
                    acquisitionRange = entity.kind.attackRange
                }
                entity.attackTarget = carrierGuardPriorityTarget(for: entity) ?? nearestTarget(for: entity, maxDistance: acquisitionRange)
            }

            guard let target = entity.attackTarget, target.isAlive else { continue }
            let distance = entity.node.position.distance(to: target.node.position)
            guard distance <= entity.kind.attackRange + target.kind.footprint * 0.35 else { continue }
            guard entity.attackTimer <= 0 else { continue }

            entity.attackTimer = effectiveAttackCooldown(for: entity)
            fire(attacker: entity, target: target)
        }
    }

    private func nearestTarget(for entity: GameEntity, maxDistance: CGFloat) -> GameEntity? {
        entities.values
            .filter { target in
                target.isAlive &&
                target.faction != entity.faction &&
                target.faction != .neutral &&
                entity.kind.canAttack(target.kind) &&
                entity.node.position.distance(to: target.node.position) <= maxDistance &&
                (entity.holdPosition == nil || target.node.position.distance(to: entity.holdPosition!) <= holdEngagementRadius + target.kind.footprint * 0.35) &&
                isKnownToFaction(target, observer: entity.faction)
            }
            .min { entity.node.position.distance(to: $0.node.position) < entity.node.position.distance(to: $1.node.position) }
    }

    private func fire(attacker: GameEntity, target: GameEntity) {
        let damage = effectiveDamage(for: attacker)
        let wasAlive = target.isAlive
        let showASWHit = shouldShowAntiSubmarineHitFeedback(for: target)
        if attacker.kind == .submarine {
            attacker.revealedUntil = max(attacker.revealedUntil, lastUpdateTime + 2.4)
            if attacker.faction == .enemy {
                attacker.node.isHidden = !isKnownToFaction(attacker, observer: .player)
            }
            if attacker.faction == .player || isKnownToFaction(attacker, observer: .player) {
                showSonarPing(at: attacker.node.position, faction: attacker.faction)
            }
        }

        if attacker.kind == .carrier {
            launchCarrierWing(from: attacker.node.position, to: target.node.position, faction: attacker.faction)
        } else {
            showProjectile(from: attacker.node.position, to: target.node.position, kind: attacker.kind)
        }

        let armorMultiplier: CGFloat
        if target.kind.isStructure && attacker.kind == .artillery {
            armorMultiplier = 1.25
        } else if target.kind.domain == .air && attacker.kind == .tank {
            armorMultiplier = 0.45
        } else if target.kind == .submarine && attacker.kind != .submarine {
            armorMultiplier = 0.78
        } else {
            armorMultiplier = 1.0
        }

        target.hp -= damage * armorMultiplier
        updateHealthBar(target)
        let appliedDamage = damage * armorMultiplier
        if shouldShowDamageFloater(for: target) {
            showDamageFloater(at: target.node.position, amount: appliedDamage, faction: attacker.faction)
        }
        if showASWHit {
            showAntiSubmarineHit(at: target.node.position, faction: attacker.faction)
        }
        if shouldShowNavalWaterImpact(attacker: attacker, target: target) {
            let side: CGFloat = target.id.isMultiple(of: 2) ? 1 : -1
            let impactPoint = target.node.position + CGPoint(
                x: side * target.kind.footprint * 0.30,
                y: -target.kind.footprint * 0.08
            )
            showNavalWaterImpact(
                at: impactPoint,
                faction: attacker.faction,
                scale: attacker.kind == .battleship ? 1.15 : 0.92
            )
        }
        if shouldShowAirMissileImpact(attacker: attacker, target: target) {
            showAirMissileImpact(at: target.node.position, faction: attacker.faction)
        }
        showPlayerUnderAttackAlertIfNeeded(target: target, attacker: attacker)
        triggerEnemyDefenseIfNeeded(target: target, attacker: attacker)
        if wasAlive && target.hp <= 0 {
            awardVeterancyKill(to: attacker, target: target)
            explode(at: target.node.position, scale: target.kind.isStructure ? 1.6 : 1.0)
        }
    }

    private func shouldShowAntiSubmarineHitFeedback(for target: GameEntity) -> Bool {
        guard target.kind == .submarine else { return false }
        return target.faction == .player || isKnownToFaction(target, observer: .player)
    }

    private func shouldShowNavalWaterImpact(attacker: GameEntity, target: GameEntity) -> Bool {
        guard target.kind.domain == .naval,
              target.kind != .submarine,
              attacker.kind == .battleship || attacker.kind == .coastalBattery || attacker.kind == .artillery
        else { return false }
        return target.faction == .player || isKnownToFaction(target, observer: .player)
    }

    private func shouldShowAirMissileImpact(attacker: GameEntity, target: GameEntity) -> Bool {
        guard target.kind.domain == .air,
              attacker.kind == .fighter || attacker.kind == .samSite || attacker.kind == .aaTruck
        else { return false }
        return target.faction == .player || isKnownToFaction(target, observer: .player)
    }

    private func effectiveDamage(for attacker: GameEntity) -> CGFloat {
        attacker.kind.damage * attacker.veterancyRank.damageMultiplier
    }

    private func effectiveAttackCooldown(for attacker: GameEntity) -> TimeInterval {
        max(0.2, attacker.kind.attackCooldown * attacker.veterancyRank.cooldownMultiplier)
    }

    private func effectiveVisionTiles(for entity: GameEntity) -> Int {
        max(0, entity.kind.visionTiles + entity.veterancyRank.visionBonus)
    }

    private func awardVeterancyKill(to attacker: GameEntity, target: GameEntity) {
        guard attacker.isAlive,
              !attacker.kind.isStructure,
              attacker.kind.damage > 0,
              attacker.faction != target.faction,
              target.faction != .neutral
        else { return }

        let previousRank = attacker.veterancyRank
        attacker.killCount += 1
        attacker.veterancyXP += veterancyXPValue(for: target)
        updateVeterancyBadge(for: attacker)

        let promotedRank = attacker.veterancyRank
        guard promotedRank != previousRank else { return }

        if attacker.faction == .player {
            showMessage(
                "\(attacker.kind.displayName) promoted to \(promotedRank.displayName).",
                color: UIColor(red: 1.0, green: 0.84, blue: 0.36, alpha: 1.0)
            )
        }
    }

    private func veterancyXPValue(for target: GameEntity) -> CGFloat {
        var xp = max(24, CGFloat(target.kind.cost) * 0.12)
        if target.kind.isStructure {
            xp *= 0.65
        }
        if target.kind == .hq {
            xp = min(xp, 180)
        }
        return xp
    }

    private func updateVeterancyBadge(for entity: GameEntity) {
        entity.veterancyNode.removeAllChildren()
        let rank = entity.veterancyRank
        entity.veterancyNode.isHidden = rank == .recruit
        guard rank != .recruit else { return }

        let back = SKShapeNode(rectOf: CGSize(width: 24, height: 13), cornerRadius: 3)
        back.fillColor = rank.badgeColor.withAlphaComponent(0.94)
        back.strokeColor = UIColor.black.withAlphaComponent(0.72)
        back.lineWidth = 1
        entity.veterancyNode.addChild(back)

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = rank.shortCode
        label.fontSize = 7
        label.fontColor = UIColor(white: 0.08, alpha: 1.0)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -0.5)
        label.zPosition = 1
        entity.veterancyNode.addChild(label)
    }

    private func showPlayerUnderAttackAlertIfNeeded(target: GameEntity, attacker: GameEntity) {
        guard target.faction == .player, attacker.faction == .enemy else { return }
        guard lastUpdateTime - lastPlayerAttackAlertTime >= 4.2 else { return }
        lastPlayerAttackAlertTime = lastUpdateTime

        showMessage("\(target.kind.displayName) under attack.", color: UIColor(red: 1.0, green: 0.36, blue: 0.24, alpha: 1.0))
        showUnderAttackPing(at: target.node.position, kind: target.kind)
    }

    private func triggerEnemyDefenseIfNeeded(target: GameEntity, attacker: GameEntity) {
        guard target.faction == .enemy, attacker.faction == .player, attacker.isAlive else { return }
        guard lastUpdateTime - lastEnemyDefenseResponseTime >= 2.6 else { return }
        lastEnemyDefenseResponseTime = lastUpdateTime

        let defenders = entities.values.filter { unit in
            unit.faction == .enemy &&
            unit.isAlive &&
            !unit.kind.isStructure &&
            unit.kind.damage > 0 &&
            unit.kind.canAttack(attacker.kind) &&
            unit.node.position.distance(to: target.node.position) <= 620
        }

        for defender in defenders.prefix(6) {
            defender.attackTarget = attacker
            if defender.node.position.distance(to: attacker.node.position) > defender.kind.attackRange * 0.88 {
                setDestination(for: defender, near: attackDestination(for: defender, target: attacker))
            }
        }

        if !defenders.isEmpty, isKnownToFaction(target, observer: .player) {
            showEnemyDefensePing(at: target.node.position)
        }
    }

    private func triggerEnemyControlPointDefenseIfNeeded(point: BattlefieldControlPoint, intruder: GameEntity) {
        guard point.faction == .enemy,
              intruder.faction == .player,
              intruder.isAlive,
              lastUpdateTime - lastEnemyControlPointDefenseResponseTime >= 3.2,
              isKnownToFaction(intruder, observer: .enemy),
              isPointKnownToEnemySensors(intruder.node.position)
        else { return }

        lastEnemyControlPointDefenseResponseTime = lastUpdateTime

        let defenders = entities.values
            .filter { unit in
                unit.faction == .enemy &&
                    unit.isAlive &&
                    !unit.kind.isStructure &&
                    unit.kind.damage > 0 &&
                    unit.kind.canAttack(intruder.kind) &&
                    !isEnemyCaptureReserved(unit) &&
                    unit.node.position.distance(to: point.node.position) <= 640
            }
            .sorted {
                $0.node.position.distance(to: point.node.position) <
                    $1.node.position.distance(to: point.node.position)
            }

        guard !defenders.isEmpty else { return }

        for defender in defenders.prefix(5) {
            defender.holdPosition = nil
            defender.attackMoveDestination = nil
            defender.attackTarget = intruder
            if defender.node.position.distance(to: intruder.node.position) > defender.kind.attackRange * 0.88 {
                setDestination(for: defender, near: attackDestination(for: defender, target: intruder))
            } else {
                defender.destination = nil
                defender.path.removeAll()
            }
        }

        if isVisible(point: point.node.position) {
            showEnemyDefensePing(at: point.node.position)
        }
    }

    private func updateHealthBar(_ entity: GameEntity) {
        let ratio = max(0, min(1, entity.hp / entity.kind.maxHP))
        entity.healthFill.xScale = ratio
        entity.healthFill.fillColor = ratio > 0.45
            ? UIColor(red: 0.28, green: 0.92, blue: 0.24, alpha: 1.0)
            : UIColor(red: 1.0, green: 0.35, blue: 0.20, alpha: 1.0)
    }

    private func cullDestroyedEntities() {
        let deadIDs = entities.values.filter { !$0.isAlive }.map(\.id)
        guard !deadIDs.isEmpty else { return }
        for id in deadIDs {
            entities[id]?.node.removeFromParent()
            entities.removeValue(forKey: id)
            selectedIDs.remove(id)
        }
        buildOrders.removeAll { deadIDs.contains($0.sourceID) }
        enemyCaptureReservations = enemyCaptureReservations.filter {
            !deadIDs.contains($0.key) && enemyCaptureTargetNeedsCapture($0.value)
        }
        enemyRetreatingUnitIDs.subtract(deadIDs)
        let deadIDSet = Set(deadIDs)
        for group in Array(controlGroups.keys) {
            controlGroups[group]?.subtract(deadIDSet)
        }
        updateProductionIndicators()
        refreshSelection()
    }

    private func updateAI(dt: TimeInterval) {
        aiAccumulator += dt
        guard aiAccumulator >= aiDifficulty.commandInterval else { return }
        aiAccumulator = 0

        let enemyHQAlive = entities.values.contains { $0.kind == .hq && $0.faction == .enemy && $0.isAlive }
        guard enemyHQAlive else { return }

        maintainEnemyCaptureReservations()
        rebuildEnemyBaseIfNeeded()

        let enemyUnits = entities.values.filter { $0.faction == .enemy && !$0.kind.isStructure && $0.isAlive }
        updateEnemyRetreatingUnits(enemyUnits)
        if enemyUnits.filter({ $0.kind == .mechanic }).count < 2 {
            queueBuild(kind: .mechanic, faction: .enemy, showFeedback: false)
        }

        _ = queueEnemyAirDefenseIfNeeded()
        _ = queueEnemyAntiSubmarineIfNeeded()

        let desired: [EntityKind] = aiBuildPattern()
        for _ in 0..<aiDifficulty.buildOrdersPerCycle {
            guard let nextBuild = nextAvailableAIBuildKind(in: desired, startingAt: aiBuildCursor) else {
                if !desired.isEmpty {
                    aiBuildCursor += 1
                }
                continue
            }
            aiBuildCursor = nextBuild.nextCursor
            _ = queueBuild(kind: nextBuild.kind, faction: .enemy, showFeedback: false)
        }

        var assignedCaptureUnitIDs = Set<Int>()
        let freeCaptureUnits = enemyUnits.filter(isAvailableEnemyCaptureUnit)

        if let neutralOil = entities.values.first(where: {
            $0.kind == .oilDerrick &&
                $0.faction != .enemy &&
                $0.isAlive &&
                !isEnemyCaptureTargetReserved(.oilDerrick($0.id))
        }),
           let oilRunner = freeCaptureUnits.first(where: { $0.kind == .mechanic }) ?? freeCaptureUnits.first(where: { $0.kind == .humvee }) {
            setDestination(for: oilRunner, near: neutralOil.node.position)
            reserveEnemyCapture(unit: oilRunner, target: .oilDerrick(neutralOil.id))
            assignedCaptureUnitIDs.insert(oilRunner.id)
        }

        let freeFlagCaptureUnits = enemyUnits.filter { unit in
            isAvailableEnemyCaptureUnit(unit) && !assignedCaptureUnitIDs.contains(unit.id)
        }
        if let targetFlag = enemyControlPointTarget(excludingReserved: true),
           let flagRunner = freeFlagCaptureUnits.first(where: { $0.kind == .humvee || $0.kind == .mechanic || $0.kind == .tank }) {
            setDestination(for: flagRunner, near: targetFlag.node.position)
            reserveEnemyCapture(unit: flagRunner, target: .controlPoint(targetFlag.id))
        }

        tryEnemySupportPower()
        updateEnemyCarrierGuardWings(enemyUnits)

        let shouldAttack = enemyUnits.count >= aiDifficulty.attackGroupSize || enemyMoney > 4800
        guard shouldAttack else { return }
        commandEnemyAttackers(enemyUnits)
    }

    private func isAvailableEnemyCaptureUnit(_ unit: GameEntity) -> Bool {
        unit.faction == .enemy &&
            unit.isAlive &&
            !unit.kind.isStructure &&
            unit.attackTarget == nil &&
            unit.attackMoveDestination == nil &&
            unit.destination == nil &&
            !isEnemyCaptureReserved(unit) &&
            unit.kind.domain == .land &&
            unit.isOperational
    }

    private func reserveEnemyCapture(unit: GameEntity, target: EnemyCaptureReservation) {
        guard isEnemyCaptureUnit(unit), enemyCaptureTargetNeedsCapture(target) else { return }
        enemyCaptureReservations[unit.id] = target
    }

    private func maintainEnemyCaptureReservations() {
        pruneEnemyCaptureReservations()

        for (unitID, reservation) in enemyCaptureReservations {
            guard let unit = entities[unitID],
                  unit.attackTarget == nil,
                  unit.attackMoveDestination == nil,
                  unit.destination == nil,
                  let targetPosition = enemyCaptureTargetPosition(for: reservation)
            else { continue }

            if unit.node.position.distance(to: targetPosition) > enemyCaptureRange(for: reservation) {
                setDestination(for: unit, near: targetPosition)
            }
        }
    }

    private func pruneEnemyCaptureReservations() {
        enemyCaptureReservations = enemyCaptureReservations.filter { unitID, reservation in
            guard let unit = entities[unitID],
                  isEnemyCaptureUnit(unit),
                  enemyCaptureTargetNeedsCapture(reservation)
            else { return false }

            return unit.attackTarget == nil && unit.attackMoveDestination == nil
        }
    }

    private func isEnemyCaptureReserved(_ unit: GameEntity) -> Bool {
        guard let reservation = enemyCaptureReservations[unit.id],
              isEnemyCaptureUnit(unit),
              enemyCaptureTargetNeedsCapture(reservation)
        else { return false }

        return unit.attackTarget == nil && unit.attackMoveDestination == nil
    }

    private func enemyCaptureTargetPosition(for reservation: EnemyCaptureReservation) -> CGPoint? {
        switch reservation {
        case .oilDerrick(let id):
            return entities[id]?.node.position
        case .controlPoint(let id):
            return controlPoints.first { $0.id == id }?.node.position
        }
    }

    private func enemyCaptureTargetNeedsCapture(_ reservation: EnemyCaptureReservation) -> Bool {
        switch reservation {
        case .oilDerrick(let id):
            guard let derrick = entities[id], derrick.kind == .oilDerrick, derrick.isAlive else { return false }
            return derrick.faction != .enemy
        case .controlPoint(let id):
            guard let controlPoint = controlPoints.first(where: { $0.id == id }) else { return false }
            return enemyControlPointNeedsAction(controlPoint)
        }
    }

    private func enemyCaptureRange(for reservation: EnemyCaptureReservation) -> CGFloat {
        switch reservation {
        case .oilDerrick:
            return 78
        case .controlPoint:
            return 92
        }
    }

    private func isEnemyCaptureTargetReserved(_ reservation: EnemyCaptureReservation) -> Bool {
        enemyCaptureReservations.values.contains(reservation)
    }

    private func isEnemyCaptureUnit(_ unit: GameEntity) -> Bool {
        unit.faction == .enemy &&
            unit.isAlive &&
            !unit.kind.isStructure &&
            unit.kind.domain == .land &&
            unit.isOperational
    }

    private func queueEnemyAirDefenseIfNeeded() -> Bool {
        let knownAirThreat = knownPlayerAirThreatCount()
        guard knownAirThreat >= 2 else { return false }

        let desiredAntiAir = desiredEnemyAntiAirCount(for: knownAirThreat)
        let committedAntiAir = enemyAntiAirAssetCount() + queuedEnemyAntiAirCount()
        guard committedAntiAir < desiredAntiAir else { return false }

        let candidates: [EntityKind] = [.aaTruck, .fighter]
        for kind in candidates where canQueueBuild(kind: kind, faction: .enemy) {
            return queueBuild(kind: kind, faction: .enemy, showFeedback: false)
        }
        return false
    }

    private func knownPlayerAirThreatCount() -> Int {
        entities.values.filter(isKnownPlayerAirThreat).count
    }

    private func isKnownPlayerAirThreat(_ entity: GameEntity) -> Bool {
        entity.faction == .player &&
            entity.kind.domain == .air &&
            entity.isAlive &&
            isKnownToFaction(entity, observer: .enemy) &&
            isPointKnownToEnemySensors(entity.node.position)
    }

    private func isPointKnownToEnemySensors(_ point: CGPoint) -> Bool {
        guard let targetTile = tile(at: point) else { return false }

        for sensor in entities.values where sensor.faction == .enemy && sensor.isAlive {
            if sensor.kind.isStructure && !sensor.isOperational {
                continue
            }
            guard let origin = tile(at: sensor.node.position) else { continue }
            let radius = effectiveVisionTiles(for: sensor)
            if hypot(CGFloat(targetTile.row - origin.row), CGFloat(targetTile.col - origin.col)) <= CGFloat(radius) {
                return true
            }
        }

        for controlPoint in controlPoints where controlPoint.faction == .enemy {
            guard let origin = tile(at: controlPoint.node.position) else { continue }
            if hypot(CGFloat(targetTile.row - origin.row), CGFloat(targetTile.col - origin.col)) <= CGFloat(controlPointVisionTiles) {
                return true
            }
        }

        return false
    }

    private func enemyAntiAirAssetCount() -> Int {
        entities.values.filter { entity in
            guard entity.faction == .enemy, entity.isAlive else { return false }
            switch entity.kind {
            case .aaTruck, .fighter:
                return true
            case .guardTower, .samSite:
                return entity.isOperational
            default:
                return false
            }
        }.count
    }

    private func queuedEnemyAntiAirCount() -> Int {
        buildOrders.filter { order in
            order.faction == .enemy &&
                (order.kind == .aaTruck || order.kind == .fighter)
        }.count
    }

    private func desiredEnemyAntiAirCount(for knownAirThreat: Int) -> Int {
        max(1, min(4, (knownAirThreat + 1) / 2))
    }

    private func queueEnemyAntiSubmarineIfNeeded() -> Bool {
        let knownSubmarineThreat = knownPlayerSubmarineThreatCount()
        guard knownSubmarineThreat >= 1 else { return false }

        let desiredASW = desiredEnemyAntiSubmarineCount(for: knownSubmarineThreat)
        let committedASW = enemyAntiSubmarineAssetCount() + queuedEnemyAntiSubmarineCount()
        guard committedASW < desiredASW else { return false }

        for kind in enemyAntiSubmarineCandidateKinds() where canQueueBuild(kind: kind, faction: .enemy) {
            return queueBuild(kind: kind, faction: .enemy, showFeedback: false)
        }
        return false
    }

    private func knownPlayerSubmarineThreatCount() -> Int {
        entities.values.filter(isKnownPlayerSubmarineThreat).count
    }

    private func isKnownPlayerSubmarineThreat(_ entity: GameEntity) -> Bool {
        entity.faction == .player &&
            entity.kind == .submarine &&
            entity.isAlive &&
            isKnownToFaction(entity, observer: .enemy) &&
            isPointKnownToEnemySensors(entity.node.position)
    }

    private func enemyAntiSubmarineAssetCount() -> Int {
        entities.values.filter { entity in
            entity.faction == .enemy &&
                entity.isAlive &&
                !entity.kind.isStructure &&
                isEnemyAntiSubmarineKind(entity.kind)
        }.count
    }

    private func queuedEnemyAntiSubmarineCount() -> Int {
        buildOrders.filter { order in
            order.faction == .enemy &&
                isEnemyAntiSubmarineKind(order.kind)
        }.count
    }

    private func desiredEnemyAntiSubmarineCount(for knownSubmarineThreat: Int) -> Int {
        max(1, min(3, (knownSubmarineThreat + 1) / 2))
    }

    private func enemyAntiSubmarineCandidateKinds() -> [EntityKind] {
        [.helicopter, .fighter, .submarine, .battleship, .carrier]
    }

    private func isEnemyAntiSubmarineKind(_ kind: EntityKind) -> Bool {
        enemyAntiSubmarineCandidateKinds().contains(kind) &&
            kind.canAttack(.submarine)
    }

    private func enemyControlPointTarget(excludingReserved: Bool = false) -> BattlefieldControlPoint? {
        controlPoints
            .filter { point in
                enemyControlPointNeedsAction(point) &&
                    (!excludingReserved || !isEnemyCaptureTargetReserved(.controlPoint(point.id)))
            }
            .max { left, right in
                let leftPriority = enemyControlPointPriority(left)
                let rightPriority = enemyControlPointPriority(right)
                if abs(leftPriority - rightPriority) > 0.001 {
                    return leftPriority < rightPriority
                }

                let leftDistance = left.node.position.distance(to: enemyBaseAnchorPoint())
                let rightDistance = right.node.position.distance(to: enemyBaseAnchorPoint())
                if abs(leftDistance - rightDistance) > 0.001 {
                    return leftDistance > rightDistance
                }

                return left.id > right.id
            }
    }

    private func enemyControlPointNeedsAction(_ point: BattlefieldControlPoint) -> Bool {
        point.faction != .enemy || isPlayerPressuringControlPoint(point)
    }

    private func isPlayerPressuringControlPoint(_ point: BattlefieldControlPoint) -> Bool {
        point.capturingFaction == .player && point.captureProgress > 0
    }

    private func enemyControlPointPriority(_ point: BattlefieldControlPoint) -> CGFloat {
        var score: CGFloat = 0
        if isPlayerPressuringControlPoint(point) {
            score += 1_400 + min(point.captureProgress, 4.0) * 32
        } else {
            switch point.faction {
            case .player:
                score += 1_000
            case .neutral:
                score += 300
            case .enemy:
                score -= 10_000
            }
        }

        let distance = point.node.position.distance(to: enemyBaseAnchorPoint())
        return score - distance * 0.02
    }

    private func enemyBaseAnchorPoint() -> CGPoint {
        tileCenter(TileCoord(row: 6, col: 20))
    }

    private func tryEnemySupportPower() {
        if let strike = bestEnemySupportStrike(), strike.score >= aiDifficulty.supportStrikeThreshold {
            executeSupportPower(strike.power, at: strike.point, faction: .enemy, showFeedback: true)
            return
        }

        if let repair = bestEnemySupportRepair(), repair.score >= aiDifficulty.supportRepairThreshold {
            executeSupportPower(.fieldRepair, at: repair.point, faction: .enemy, showFeedback: true)
            return
        }

        guard aiDifficulty.usesReconSupport,
              enemyMoney >= SupportPower.reconSweep.cost + aiDifficulty.supportSpendReserve,
              supportIssue(for: .reconSweep, faction: .enemy) == nil,
              let reconPoint = enemyReconSupportPoint()
        else { return }

        executeSupportPower(.reconSweep, at: reconPoint, faction: .enemy, showFeedback: true)
    }

    private func bestEnemySupportStrike() -> (power: SupportPower, point: CGPoint, score: CGFloat)? {
        let powers: [SupportPower] = [.airStrike, .navalBarrage]
        let targets = entities.values.filter { entity in
            entity.faction == .player &&
            entity.isAlive &&
            isKnownToFaction(entity, observer: .enemy)
        }
        guard !targets.isEmpty else { return nil }

        var best: (power: SupportPower, point: CGPoint, score: CGFloat)?
        for power in powers {
            guard enemyMoney >= power.cost + aiDifficulty.supportSpendReserve,
                  supportIssue(for: power, faction: .enemy) == nil
            else { continue }

            for target in targets {
                let point = target.node.position
                let score = supportStrikeScore(power, at: point, from: .enemy)
                if best == nil || score > best!.score {
                    best = (power, point, score)
                }
            }
        }

        return best
    }

    private func bestEnemySupportRepair() -> (point: CGPoint, score: CGFloat)? {
        let power = SupportPower.fieldRepair
        guard enemyMoney >= power.cost + aiDifficulty.supportSpendReserve,
              supportIssue(for: power, faction: .enemy) == nil
        else { return nil }

        let damagedAssets = entities.values.filter { entity in
            entity.faction == .enemy &&
            entity.isAlive &&
            entity.hp < entity.kind.maxHP * 0.88
        }
        guard !damagedAssets.isEmpty else { return nil }

        var best: (point: CGPoint, score: CGFloat)?
        for asset in damagedAssets {
            let point = asset.node.position
            let score = supportRepairScore(power, at: point, for: .enemy)
            if best == nil || score > best!.score {
                best = (point, score)
            }
        }

        return best
    }

    private func supportStrikeScore(_ power: SupportPower, at point: CGPoint, from faction: Faction) -> CGFloat {
        guard power.damage > 0 else { return 0 }

        var score: CGFloat = 0
        var mobileTargets = 0
        for entity in entities.values where entity.faction != faction && entity.faction != .neutral && entity.isAlive {
            guard isKnownToFaction(entity, observer: faction) else { continue }

            let distance = entity.node.position.distance(to: point)
            guard distance <= power.radius + entity.kind.footprint * 0.35 else { continue }

            let falloff = max(0.42, 1.0 - distance / max(power.radius, 1))
            let structureMultiplier: CGFloat = entity.kind.isStructure ? 0.72 : 1.0
            let expectedDamage = min(entity.hp, power.damage * falloff * structureMultiplier)
            let value = strategicValue(of: entity.kind)
            let damageRatio = expectedDamage / max(entity.kind.maxHP, 1)

            score += expectedDamage * 1.1
            score += value * damageRatio
            if expectedDamage >= entity.hp {
                score += value * 0.45
            }
            if distance <= entity.kind.footprint * 0.45 {
                score += value * (entity.kind.isStructure ? 0.58 : 0.18)
            }
            if !entity.kind.isStructure {
                mobileTargets += 1
            }
        }

        if mobileTargets >= 3 {
            score += CGFloat(mobileTargets - 2) * 180
        }

        return score - CGFloat(power.cost) * 0.12
    }

    private func supportRepairScore(_ power: SupportPower, at point: CGPoint, for faction: Faction) -> CGFloat {
        guard power.repairAmount > 0 else { return 0 }

        var score: CGFloat = 0
        var repairedAssets = 0
        for entity in entities.values where entity.faction == faction && entity.isAlive && entity.hp < entity.kind.maxHP {
            let distance = entity.node.position.distance(to: point)
            guard distance <= power.radius + entity.kind.footprint * 0.35 else { continue }

            let falloff = max(0.55, 1.0 - distance / max(power.radius, 1))
            let structureMultiplier: CGFloat = entity.kind.isStructure ? 0.82 : 1.0
            let expectedRepair = min(entity.kind.maxHP - entity.hp, power.repairAmount * falloff * structureMultiplier)
            guard expectedRepair > 0 else { continue }

            let repairRatio = expectedRepair / max(entity.kind.maxHP, 1)
            score += expectedRepair * 0.95
            score += strategicValue(of: entity.kind) * repairRatio
            if entity.hp < entity.kind.maxHP * 0.35 {
                score += strategicValue(of: entity.kind) * 0.20
            }
            if entity.kind.isStructure {
                score += 85
            }
            if faction == .enemy && isProtectedEnemyVeteranCombatUnit(entity) {
                score += strategicValue(of: entity.kind) * 0.28
            }
            if faction == .enemy && (isEnemyUnitRetreating(entity) || shouldRetreatEnemyAssaultUnit(entity)) {
                score += strategicValue(of: entity.kind) * 0.18
            }
            repairedAssets += 1
        }

        if repairedAssets >= 3 {
            score += CGFloat(repairedAssets - 2) * 130
        }

        return score - CGFloat(power.cost) * 0.08
    }

    private func enemyReconSupportPoint() -> CGPoint? {
        if let knownSubmarine = entities.values
            .filter(isKnownPlayerSubmarineThreat)
            .max(by: { enemyReconKnownSubmarineScore($0) < enemyReconKnownSubmarineScore($1) }) {
            return knownSubmarine.node.position
        }

        return enemyReconPatrolHotspot()
    }

    private func enemyReconKnownSubmarineScore(_ entity: GameEntity) -> CGFloat {
        strategicValue(of: entity.kind) - entity.node.position.distance(to: enemyBaseAnchorPoint()) * 0.04
    }

    private func enemyReconPatrolHotspot() -> CGPoint? {
        enemyReconPatrolHotspotCandidates().max { $0.score < $1.score }?.point
    }

    private func enemyReconPatrolHotspotCandidates() -> [(point: CGPoint, score: CGFloat)] {
        enemyReconPatrolAnchors().flatMap { anchor in
            enemyReconHotspotCandidates(around: anchor.point).map { candidate in
                let terrainBonus: CGFloat = terrain(at: candidate.tile) == .water ? 34 : 18
                let distancePenalty = candidate.point.distance(to: anchor.point) * 0.055
                return (point: candidate.point, score: anchor.weight + terrainBonus - distancePenalty)
            }
        }
    }

    private func enemyReconPatrolAnchors() -> [(point: CGPoint, weight: CGFloat)] {
        let sonarAnchors: [(point: CGPoint, weight: CGFloat)] = entities.values.compactMap { entity in
            guard entity.faction == .enemy, isActiveSonarSensor(entity) else { return nil }
            let weight: CGFloat = entity.kind == .sonarBuoy ? 74 : 56
            return (point: entity.node.position, weight: weight)
        }
        let flagAnchors = controlPoints
            .filter { $0.faction == .enemy }
            .map { (point: $0.node.position, weight: CGFloat(42)) }
        return sonarAnchors + flagAnchors
    }

    private func enemyReconHotspotCandidates(around anchor: CGPoint) -> [(tile: TileCoord, point: CGPoint)] {
        guard let origin = tile(at: anchor) else { return [] }
        var candidates: [(tile: TileCoord, point: CGPoint)] = []
        for radius in 0...5 {
            for row in max(0, origin.row - radius)...min(rows - 1, origin.row + radius) {
                for col in max(0, origin.col - radius)...min(cols - 1, origin.col + radius) {
                    let tile = TileCoord(row: row, col: col)
                    guard terrain(at: tile) == .water || isCoastal(tile) else { continue }
                    candidates.append((tile: tile, point: tileCenter(tile)))
                }
            }
        }
        return candidates
    }

    private func updateEnemyRetreatingUnits(_ enemyUnits: [GameEntity]) {
        for id in Array(enemyRetreatingUnitIDs) {
            guard let unit = entities[id],
                  unit.faction == .enemy,
                  unit.isAlive,
                  isEnemyAssaultRetreatEligible(unit),
                  healthRatio(of: unit) < enemyRetreatRecoveryThreshold
            else {
                if let unit = entities[id] {
                    unit.holdPosition = nil
                    if unit.attackTarget == nil && unit.attackMoveDestination == nil {
                        unit.destination = nil
                        unit.path.removeAll()
                    }
                }
                enemyRetreatingUnitIDs.remove(id)
                continue
            }

            if unit.attackTarget != nil {
                unit.holdPosition = nil
                enemyRetreatingUnitIDs.remove(id)
            } else if unit.attackMoveDestination != nil ||
                unit.destination == nil {
                retreatEnemyAssaultUnit(unit)
            }
        }

        for unit in enemyUnits where unit.attackMoveDestination != nil && shouldRetreatEnemyAssaultUnit(unit) {
            retreatEnemyAssaultUnit(unit)
        }
    }

    private func retreatEnemyAssaultUnits(_ units: [GameEntity]) -> Set<Int> {
        var retreatingIDs = Set<Int>()
        for unit in units where shouldRetreatEnemyAssaultUnit(unit) {
            retreatEnemyAssaultUnit(unit)
            retreatingIDs.insert(unit.id)
        }
        return retreatingIDs
    }

    private func retreatEnemyAssaultUnit(_ unit: GameEntity) {
        guard isEnemyAssaultRetreatEligible(unit) else { return }

        let retreatPoint = enemyRetreatDestination(for: unit)
        enemyRetreatingUnitIDs.insert(unit.id)
        unit.attackMoveDestination = nil
        unit.attackTarget = nil
        unit.holdPosition = retreatPoint
        setDestination(for: unit, near: retreatPoint)
    }

    private func shouldRetreatEnemyAssaultUnit(_ unit: GameEntity) -> Bool {
        isEnemyAssaultRetreatEligible(unit) &&
            healthRatio(of: unit) < enemyRetreatHealthThreshold
    }

    private func isEnemyUnitRetreating(_ unit: GameEntity) -> Bool {
        enemyRetreatingUnitIDs.contains(unit.id) &&
            isEnemyAssaultRetreatEligible(unit) &&
            healthRatio(of: unit) < enemyRetreatRecoveryThreshold
    }

    private func isEnemyAssaultRetreatEligible(_ unit: GameEntity) -> Bool {
        unit.faction == .enemy &&
            unit.isAlive &&
            !unit.kind.isStructure &&
            unit.kind.damage > 0 &&
            unit.isOperational &&
            !isEnemyCaptureReserved(unit)
    }

    private func updateEnemyCarrierGuardWings(_ enemyUnits: [GameEntity]) {
        var assignedWingIDs = Set<Int>()
        let carriers = enemyUnits.filter { carrier in
            carrier.kind == .carrier &&
                carrier.isOperational &&
                carrier.attackTarget == nil &&
                carrier.attackMoveDestination == nil &&
                carrier.destination == nil &&
                !isEnemyUnitRetreating(carrier)
        }

        for carrier in carriers {
            let currentWing = boundCarrierGuardWing(for: carrier).filter { !assignedWingIDs.contains($0.id) }
            let currentWingIDs = Set(currentWing.map(\.id))
            let missing = max(0, carrierGuardWingRequirement - currentWing.count)
            guard missing > 0 else {
                assignedWingIDs.formUnion(currentWingIDs)
                continue
            }

            let candidates = nearbyCarrierAirWing(for: carrier).filter { wing in
                !assignedWingIDs.contains(wing.id) &&
                    !currentWingIDs.contains(wing.id) &&
                    isAvailableEnemyCarrierGuardWing(wing) &&
                    (wing.guardAnchorCarrierID == nil || carrierGuardAnchor(for: wing)?.id == carrier.id)
            }
            guard !candidates.isEmpty else {
                assignedWingIDs.formUnion(currentWingIDs)
                continue
            }

            carrier.holdPosition = carrier.node.position
            carrier.attackTarget = nil
            carrier.attackMoveDestination = nil
            carrier.destination = nil
            carrier.path.removeAll()

            for wing in candidates.prefix(missing) {
                wing.holdPosition = wing.node.position
                wing.guardAnchorCarrierID = carrier.id
                wing.attackMoveDestination = nil
                wing.attackTarget = nil
                wing.destination = nil
                wing.path.removeAll()
                assignedWingIDs.insert(wing.id)
            }
            assignedWingIDs.formUnion(currentWingIDs)
        }
    }

    private func isAvailableEnemyCarrierGuardWing(_ unit: GameEntity) -> Bool {
        unit.faction == .enemy &&
            unit.isAlive &&
            unit.isOperational &&
            !unit.kind.isStructure &&
            (unit.kind == .helicopter || unit.kind == .fighter) &&
            unit.attackTarget == nil &&
            unit.attackMoveDestination == nil &&
            unit.destination == nil &&
            !isEnemyCaptureReserved(unit) &&
            !isEnemyUnitRetreating(unit)
    }

    private func isEnemyCarrierGuardWingReservedForAnchor(_ unit: GameEntity) -> Bool {
        unit.faction == .enemy &&
            (unit.kind == .helicopter || unit.kind == .fighter) &&
            carrierGuardAnchor(for: unit) != nil
    }

    private func enemyRetreatDestination(for unit: GameEntity) -> CGPoint {
        enemyRepairAnchor(for: unit) ?? enemyBaseAnchorPoint()
    }

    private func enemyRepairAnchor(for unit: GameEntity) -> CGPoint? {
        let mechanics = entities.values.filter { candidate in
            candidate.faction == .enemy &&
                candidate.isAlive &&
                candidate.kind == .mechanic &&
                candidate.id != unit.id
        }
        guard let mechanic = mechanics.min(by: { left, right in
            left.node.position.distance(to: unit.node.position) <
                right.node.position.distance(to: unit.node.position)
        }) else { return nil }

        return mechanic.node.position
    }

    private func commandEnemyAttackers(_ enemyUnits: [GameEntity]) {
        let idleAttackers = enemyUnits.filter { unit in
            unit.attackTarget == nil &&
            unit.attackMoveDestination == nil &&
            unit.destination == nil &&
            !isEnemyCaptureReserved(unit) &&
            !isEnemyCarrierGuardWingReservedForAnchor(unit) &&
            !isEnemyUnitRetreating(unit) &&
            unit.kind.damage > 0 &&
            unit.isOperational
        }
        guard !idleAttackers.isEmpty else { return }

        guard let objective = enemyWaveObjective() else {
            for unit in idleAttackers {
                guard let target = tacticalTarget(for: unit) else { continue }
                unit.attackMoveDestination = nil
                unit.attackTarget = target
                if unit.node.position.distance(to: target.node.position) > unit.kind.attackRange * 0.88 {
                    setDestination(for: unit, near: attackDestination(for: unit, target: target))
                }
            }
            return
        }

        let waveSize = min(idleAttackers.count, max(aiDifficulty.attackGroupSize + 2, idleAttackers.count / 2))
        let provisionalWave = enemyProvisionalAssaultWave(from: idleAttackers, toward: objective, waveSize: waveSize)
        let assaultCandidates = enemyAssaultCandidatesWithCarrierGuardWings(from: provisionalWave)
        let retreatingIDs = retreatEnemyAssaultUnits(provisionalWave)
        let availableCandidates = enemyAssaultCandidates(
            from: assaultCandidates,
            excludingRetreatingIDs: retreatingIDs
        )
        let acceptedWave = enemyAssaultWave(from: availableCandidates)
        let wave = enemyAssaultWaveKeepingCarrierGuardAnchors(acceptedWave)
        guard !wave.isEmpty else { return }

        updateEnemyAssaultWaveSummary(for: wave)
        issueFormationMove(to: objective, units: wave, showMarkers: false, showFeedback: false, attackMove: true)
    }

    private func updateEnemyAssaultWaveSummary(for wave: [GameEntity]) {
        let knownWave = wave.filter { isKnownToFaction($0, observer: .player) }
        guard !knownWave.isEmpty else { return }
        lastEnemyAssaultWaveSummary = enemyAssaultWaveSummary(for: knownWave)
        lastEnemyAssaultWaveSummaryTime = lastUpdateTime
    }

    private func currentEnemyAssaultWaveSummary() -> String? {
        guard let summary = lastEnemyAssaultWaveSummary,
              lastUpdateTime - lastEnemyAssaultWaveSummaryTime <= enemyAssaultWaveSummaryDuration
        else { return nil }
        return summary
    }

    private func enemyAssaultWaveSummary(for wave: [GameEntity]) -> String {
        let land = wave.filter { $0.kind.domain == .land }.count
        let air = wave.filter { $0.kind.domain == .air }.count
        let naval = wave.filter { $0.kind.domain == .naval }.count
        let carriers = wave.filter { $0.kind == .carrier }.count
        let helicopters = wave.filter { $0.kind == .helicopter }.count
        let fighters = wave.filter { $0.kind == .fighter }.count

        var parts = ["Seen \(wave.count)", "L\(land)/A\(air)/N\(naval)"]
        if carriers > 0 { parts.append("CV\(carriers)") }
        if helicopters > 0 { parts.append("H\(helicopters)") }
        if fighters > 0 { parts.append("J\(fighters)") }
        return parts.joined(separator: " ")
    }

    private func enemyAssaultCandidatesWithCarrierGuardWings(from provisionalWave: [GameEntity]) -> [GameEntity] {
        var candidates = provisionalWave
        var candidateIDs = Set(provisionalWave.map(\.id))

        for carrier in provisionalWave where carrier.faction == .enemy && carrier.kind == .carrier {
            let guardWing = boundCarrierGuardWing(for: carrier).filter { wing in
                !candidateIDs.contains(wing.id) &&
                    canEnemyCarrierGuardWingJoinAssault(wing, with: carrier)
            }
            for wing in guardWing {
                candidates.append(wing)
                candidateIDs.insert(wing.id)
            }
        }

        return candidates
    }

    private func canEnemyCarrierGuardWingJoinAssault(_ wing: GameEntity, with carrier: GameEntity) -> Bool {
        wing.faction == .enemy &&
            wing.isAlive &&
            wing.isOperational &&
            !wing.kind.isStructure &&
            (wing.kind == .helicopter || wing.kind == .fighter) &&
            wing.attackTarget == nil &&
            wing.attackMoveDestination == nil &&
            !isEnemyCaptureReserved(wing) &&
            !isEnemyUnitRetreating(wing) &&
            !shouldRetreatEnemyAssaultUnit(wing) &&
            carrierGuardAnchor(for: wing)?.id == carrier.id
    }

    private func enemyAssaultCandidates(
        from candidates: [GameEntity],
        excludingRetreatingIDs retreatingIDs: Set<Int>
    ) -> [GameEntity] {
        candidates.filter { unit in
            guard !retreatingIDs.contains(unit.id) else { return false }
            guard isEnemyCarrierGuardWingReservedForAnchor(unit),
                  let carrier = carrierGuardAnchor(for: unit)
            else { return true }
            return !retreatingIDs.contains(carrier.id)
        }
    }

    private func enemyAssaultWaveKeepingCarrierGuardAnchors(_ acceptedWave: [GameEntity]) -> [GameEntity] {
        let acceptedIDs = Set(acceptedWave.map(\.id))
        return acceptedWave.filter { unit in
            guard isEnemyCarrierGuardWingReservedForAnchor(unit),
                  let carrier = carrierGuardAnchor(for: unit)
            else { return true }
            return acceptedIDs.contains(carrier.id)
        }
    }

    private func enemyProvisionalAssaultWave(from candidates: [GameEntity], toward objective: CGPoint, waveSize: Int) -> [GameEntity] {
        let ordered = sortedEnemyAssaultCandidates(candidates, toward: objective)
        var selected: [GameEntity] = []

        appendEnemyAssaultRole(from: ordered, to: &selected, waveSize: waveSize, limit: 2) { unit in
            unit.kind == .humvee || unit.kind == .tank
        }
        appendEnemyAssaultRole(from: ordered, to: &selected, waveSize: waveSize, limit: 1) { unit in
            unit.kind == .aaTruck || unit.kind == .fighter
        }
        appendEnemyAssaultRole(from: ordered, to: &selected, waveSize: waveSize, limit: 1) { unit in
            unit.kind == .artillery || unit.kind == .battleship
        }
        appendEnemyAssaultRole(from: ordered, to: &selected, waveSize: waveSize, limit: 1) { unit in
            unit.kind == .helicopter || unit.kind == .fighter
        }
        appendEnemyAssaultRole(from: ordered, to: &selected, waveSize: waveSize, limit: 1) { unit in
            unit.kind == .submarine || unit.kind == .battleship || unit.kind == .carrier
        }

        for candidate in ordered where selected.count < waveSize && !selected.contains(where: { $0.id == candidate.id }) {
            selected.append(candidate)
        }

        return selected
    }

    private func sortedEnemyAssaultCandidates(_ candidates: [GameEntity], toward objective: CGPoint) -> [GameEntity] {
        candidates.sorted { left, right in
            let leftDistance = left.node.position.distance(to: objective)
            let rightDistance = right.node.position.distance(to: objective)
            if abs(leftDistance - rightDistance) < 0.001 {
                return formationPriority(for: left.kind) < formationPriority(for: right.kind)
            }
            return leftDistance < rightDistance
        }
    }

    private func appendEnemyAssaultRole(
        from candidates: [GameEntity],
        to selected: inout [GameEntity],
        waveSize: Int,
        limit: Int,
        matching matches: (GameEntity) -> Bool
    ) {
        var added = 0
        for candidate in candidates where selected.count < waveSize && added < limit {
            guard matches(candidate), !selected.contains(where: { $0.id == candidate.id }) else { continue }
            selected.append(candidate)
            added += 1
        }
    }

    private func enemyAssaultWave(from provisionalWave: [GameEntity]) -> [GameEntity] {
        provisionalWave.filter { unit in
            canJoinEnemyAssaultWave(unit, provisionalWave: provisionalWave)
        }
    }

    private func canJoinEnemyAssaultWave(_ unit: GameEntity, provisionalWave: [GameEntity]) -> Bool {
        guard !isProtectedEnemyVeteranCombatUnit(unit) else { return false }
        guard isHighValueNavalAssaultUnit(unit) else { return true }

        let escortRequirement = unit.kind == .carrier ? 2 : 1
        let waveEscorts = provisionalWave.filter(isEnemyAssaultEscort).count
        if waveEscorts >= max(aiDifficulty.attackGroupSize, escortRequirement + 1) {
            return true
        }

        return enemyEscortCount(near: unit, in: provisionalWave) >= escortRequirement
    }

    private func isProtectedEnemyVeteranCombatUnit(_ unit: GameEntity) -> Bool {
        unit.faction == .enemy &&
            unit.isAlive &&
            !unit.kind.isStructure &&
            unit.kind.damage > 0 &&
            unit.isOperational &&
            (unit.veterancyRank == .veteran || unit.veterancyRank == .elite) &&
            healthRatio(of: unit) < 0.55
    }

    private func healthRatio(of unit: GameEntity) -> CGFloat {
        guard unit.kind.maxHP > 0 else { return 0 }
        return unit.hp / unit.kind.maxHP
    }

    private func isHighValueNavalAssaultUnit(_ unit: GameEntity) -> Bool {
        unit.faction == .enemy &&
            unit.isAlive &&
            (unit.kind == .battleship || unit.kind == .carrier)
    }

    private func isEnemyAssaultEscort(_ unit: GameEntity) -> Bool {
        unit.faction == .enemy &&
            unit.isAlive &&
            !unit.kind.isStructure &&
            unit.kind.damage > 0 &&
            unit.isOperational &&
            !isEnemyCaptureReserved(unit) &&
            !isHighValueNavalAssaultUnit(unit)
    }

    private func enemyEscortCount(near unit: GameEntity, in candidates: [GameEntity]) -> Int {
        candidates.filter { escort in
            isEnemyAssaultEscort(escort) &&
                escort.id != unit.id &&
                escort.node.position.distance(to: unit.node.position) <= 620
        }.count
    }

    private func enemyWaveObjective() -> CGPoint? {
        if let targetFlag = enemyControlPointTarget() {
            return targetFlag.node.position
        }

        if let oil = entities.values
            .filter({ $0.kind == .oilDerrick && $0.faction != .enemy && $0.isAlive && $0.isOperational })
            .min(by: { $0.node.position.distance(to: enemyBaseAnchorPoint()) < $1.node.position.distance(to: enemyBaseAnchorPoint()) }) {
            return oil.node.position
        }

        if let target = enemyStrategicAssaultTarget() {
            return target.node.position
        }

        return primaryTarget(for: .enemy)?.node.position
    }

    private func enemyStrategicAssaultTarget() -> GameEntity? {
        entities.values
            .filter { target in
                target.faction == .player &&
                target.isAlive &&
                target.kind.isStructure &&
                isKnownToFaction(target, observer: .enemy)
            }
            .max { left, right in
                enemyStrategicAssaultScore(left) < enemyStrategicAssaultScore(right)
            }
    }

    private func enemyStrategicAssaultScore(_ target: GameEntity) -> CGFloat {
        let distance = target.node.position.distance(to: enemyBaseAnchorPoint())
        var score = strategicValue(of: target.kind) - distance * 0.12
        if target.kind == .hq {
            score += controlPointCount(for: .enemy) >= 2 ? 240 : -180
        }
        if target.kind == .oilDerrick {
            score += 140
        }
        if target.kind == .radarOutpost {
            score += 90
        }
        if target.kind == .sonarBuoy {
            score += 96
        }
        if target.kind == .guardTower {
            score += 110
        }
        if target.kind == .samSite {
            score += 118
        }
        if target.kind == .coastalBattery {
            score += 125
        }
        if isCoastalInfrastructure(target.kind), hasActiveCoastalAssaultNavy(for: .enemy) {
            score += target.kind == .shipyard ? 210 : 170
        }
        if target.hp < target.kind.maxHP * 0.42 {
            score += 120
        }
        return score
    }

    private func rebuildEnemyBaseIfNeeded() {
        let missingStructures = buildableStructures.filter { kind in
            !entities.values.contains { $0.kind == kind && $0.faction == .enemy && $0.isAlive }
        }
        guard let kind = missingStructures.first, enemyMoney >= kind.cost else { return }
        guard let position = enemyConstructionPosition(for: kind) else { return }

        if kind == .oilDerrick, let existing = oilDerrick(at: position), existing.faction != .enemy {
            changeMoney(for: .enemy, by: -kind.cost)
            setFaction(.enemy, for: existing)
            existing.hp = existing.kind.maxHP
            startConstruction(for: existing)
            updateHealthBar(existing)
            showConstructionPulse(at: existing.node.position)
            return
        }

        changeMoney(for: .enemy, by: -kind.cost)
        let structure = addEntity(kind: kind, faction: .enemy, at: position)
        startConstruction(for: structure)
        showConstructionPulse(at: position)
    }

    private func enemyConstructionPosition(for kind: EntityKind) -> CGPoint? {
        if kind == .oilDerrick {
            let candidates = [enemyOilTile()] + neutralOilTiles()
            for tile in candidates where constructionIssue(for: kind, faction: .enemy, tile: tile, position: tileCenter(tile)) == nil {
                return tileCenter(tile)
            }
            return nil
        }

        let anchors = buildCoverageAnchors(for: .enemy)
            .sorted { $0.distance(to: enemyBaseAnchorPoint()) < $1.distance(to: enemyBaseAnchorPoint()) }

        for anchor in anchors {
            guard let origin = tile(at: anchor) else { continue }
            for radius in 1...6 {
                for row in max(0, origin.row - radius)...min(rows - 1, origin.row + radius) {
                    for col in max(0, origin.col - radius)...min(cols - 1, origin.col + radius) {
                        let tile = TileCoord(row: row, col: col)
                        let position = tileCenter(tile)
                        if constructionIssue(for: kind, faction: .enemy, tile: tile, position: position) == nil {
                            return position
                        }
                    }
                }
            }
        }
        return nil
    }

    private func buildCoverageAnchors(for faction: Faction) -> [CGPoint] {
        let structureAnchors = entities.values
            .filter { $0.faction == faction && $0.isAlive && $0.kind.isStructure && $0.isOperational }
            .map(\.node.position)
        let flagAnchors = controlPoints
            .filter { $0.faction == faction }
            .map(\.node.position)
        return structureAnchors + flagAnchors
    }

    private func aiBuildPattern() -> [EntityKind] {
        switch aiDifficulty {
        case .easy:
            return [.humvee, .tank, .aaTruck, .artillery, .tank, .helicopter, .battleship]
        case .normal:
            return [.humvee, .tank, .aaTruck, .artillery, .helicopter, .fighter, .tank, .submarine, .battleship, .carrier]
        case .hard:
            return [.humvee, .tank, .aaTruck, .artillery, .fighter, .helicopter, .tank, .submarine, .battleship, .carrier]
        }
    }

    private func nextAvailableAIBuildKind(in pattern: [EntityKind], startingAt cursor: Int) -> (kind: EntityKind, nextCursor: Int)? {
        guard !pattern.isEmpty else { return nil }
        for offset in 0..<pattern.count {
            let candidate = pattern[(cursor + offset) % pattern.count]
            if canQueueBuild(kind: candidate, faction: .enemy) {
                return (candidate, cursor + offset + 1)
            }
        }
        return nil
    }

    private func tacticalTarget(for attacker: GameEntity) -> GameEntity? {
        entities.values
            .filter { target in
                target.isAlive &&
                target.faction != attacker.faction &&
                target.faction != .neutral &&
                attacker.kind.canAttack(target.kind) &&
                isKnownToFaction(target, observer: attacker.faction)
            }
            .max { left, right in
                targetScore(for: attacker, target: left) < targetScore(for: attacker, target: right)
            }
    }

    private func targetScore(for attacker: GameEntity, target: GameEntity) -> CGFloat {
        var score = strategicValue(of: target.kind)
        let distance = attacker.node.position.distance(to: target.node.position)

        if target.kind.canAttack(attacker.kind) {
            score += 190
        }
        if distance <= attacker.kind.attackRange + target.kind.footprint * 0.35 {
            score += 160
        }
        if target.kind == .submarine {
            score += attacker.kind.hasSonar ? 120 : 35
        }
        if attacker.kind == .submarine && target.kind.domain == .naval {
            score += 180
        }
        if attacker.kind == .fighter && target.kind.domain == .air {
            score += 170
        }
        if attacker.kind == .battleship && target.kind.isStructure {
            score += 130
        }
        if attacker.kind == .carrier && (target.kind == .shipyard || target.kind == .airfield || target.kind == .carrier) {
            score += 150
        }
        if attacker.faction == .enemy && isCoastalAssaultNavalUnit(attacker) && isCoastalInfrastructure(target.kind) {
            score += attacker.kind == .carrier || attacker.kind == .battleship ? 150 : 110
        }
        if target.hp < target.kind.maxHP * 0.35 {
            score += 95
        }

        return score - distance * 0.18
    }

    private func isCoastalInfrastructure(_ kind: EntityKind) -> Bool {
        kind == .shipyard || kind == .sonarBuoy || kind == .coastalBattery
    }

    private func hasActiveCoastalAssaultNavy(for faction: Faction) -> Bool {
        entities.values.contains { isCoastalAssaultNavalUnit($0) && $0.faction == faction }
    }

    private func isCoastalAssaultNavalUnit(_ entity: GameEntity) -> Bool {
        entity.isAlive &&
            entity.isOperational &&
            !entity.kind.isStructure &&
            entity.kind.domain == .naval &&
            entity.kind.damage > 0 &&
            isCoastalInfrastructureAttackCapable(entity.kind)
    }

    private func isCoastalInfrastructureAttackCapable(_ kind: EntityKind) -> Bool {
        kind.canAttack(.shipyard) || kind.canAttack(.sonarBuoy) || kind.canAttack(.coastalBattery)
    }

    private func strategicValue(of kind: EntityKind) -> CGFloat {
        switch kind {
        case .hq:
            1000
        case .carrier:
            860
        case .shipyard:
            800
        case .airfield:
            760
        case .barracks:
            720
        case .battleship:
            690
        case .coastalBattery:
            680
        case .samSite:
            670
        case .guardTower:
            660
        case .submarine:
            640
        case .fighter:
            610
        case .artillery:
            590
        case .oilDerrick:
            560
        case .radarOutpost:
            620
        case .sonarBuoy:
            600
        case .helicopter:
            540
        case .aaTruck:
            520
        case .tank:
            500
        case .mechanic:
            430
        case .humvee:
            360
        }
    }

    private func attackDestination(for attacker: GameEntity, target: GameEntity) -> CGPoint {
        switch attacker.kind.domain {
        case .air:
            let slot = attacker.id % 8
            let angle = CGFloat(slot) * (.pi / 4)
            let radius = max(airAttackStationRadius, target.kind.footprint * 0.78)
            return target.node.position + CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius * 0.64
            )
        case .land, .naval:
            if let firingPoint = firingPosition(for: attacker, target: target) {
                return firingPoint
            }
            return target.node.position
        case .structure:
            return attacker.node.position
        }
    }

    private func firingPosition(for attacker: GameEntity, target: GameEntity) -> CGPoint? {
        guard let targetTile = tile(at: target.node.position) else { return nil }
        let domain = attacker.kind.domain
        var bestPoint: CGPoint?
        var bestDistance = CGFloat.greatestFiniteMagnitude
        let searchRadius = max(1, Int(ceil((attacker.kind.attackRange + target.kind.footprint) / min(tileWidth, tileHeight))))

        for radius in 0...searchRadius {
            for row in max(0, targetTile.row - radius)...min(rows - 1, targetTile.row + radius) {
                for col in max(0, targetTile.col - radius)...min(cols - 1, targetTile.col + radius) {
                    let tile = TileCoord(row: row, col: col)
                    guard isPassable(tile, for: domain) else { continue }
                    let point = tileCenter(tile)
                    let range = point.distance(to: target.node.position)
                    guard range <= attacker.kind.attackRange * 0.86 else { continue }
                    let travelDistance = attacker.node.position.distance(to: point)
                    if travelDistance < bestDistance {
                        bestDistance = travelDistance
                        bestPoint = point
                    }
                }
            }
            if bestPoint != nil {
                break
            }
        }

        return bestPoint
    }

    private func primaryTarget(for faction: Faction) -> GameEntity? {
        let enemyFaction: Faction = faction == .enemy ? .player : .enemy
        let priorities: [EntityKind] = [.hq, .oilDerrick, .shipyard, .airfield, .barracks, .coastalBattery, .samSite, .guardTower, .sonarBuoy, .radarOutpost, .carrier, .battleship]
        for kind in priorities {
            if let target = entities.values.first(where: { $0.faction == enemyFaction && $0.kind == kind && $0.isAlive && isKnownToFaction($0, observer: faction) }) {
                return target
            }
        }
        return entities.values.first { $0.faction == enemyFaction && $0.isAlive && isKnownToFaction($0, observer: faction) }
    }

    private func updateVictoryState() {
        let playerHQAlive = entities.values.contains { $0.kind == .hq && $0.faction == .player && $0.isAlive }
        let enemyHQAlive = entities.values.contains { $0.kind == .hq && $0.faction == .enemy && $0.isAlive }
        if !enemyHQAlive {
            victoryState = "Victory: enemy HQ destroyed."
            showMessage(victoryState ?? "", color: UIColor(red: 0.75, green: 1.0, blue: 0.55, alpha: 1.0))
        } else if !playerHQAlive {
            victoryState = "Defeat: command HQ lost."
            showMessage(victoryState ?? "", color: UIColor(red: 1.0, green: 0.45, blue: 0.35, alpha: 1.0))
        }
    }

    private func updateFog(force: Bool, dt: TimeInterval = 0) {
        if !force {
            fogAccumulator += dt
            guard fogAccumulator >= 0.28 else { return }
            fogAccumulator = 0
        }

        var visible = Set<TileCoord>()
        let playerEntities = entities.values.filter { $0.faction == .player && $0.isAlive }
        for entity in playerEntities {
            if entity.kind.isStructure && !entity.isOperational {
                continue
            }
            guard let origin = tile(at: entity.node.position) else { continue }
            let radius = effectiveVisionTiles(for: entity)
            for row in max(0, origin.row - radius)...min(rows - 1, origin.row + radius) {
                for col in max(0, origin.col - radius)...min(cols - 1, origin.col + radius) {
                    let tile = TileCoord(row: row, col: col)
                    if hypot(CGFloat(row - origin.row), CGFloat(col - origin.col)) <= CGFloat(radius) {
                        visible.insert(tile)
                    }
                }
            }
        }
        for point in controlPoints where point.faction == .player {
            guard let origin = tile(at: point.node.position) else { continue }
            for row in max(0, origin.row - controlPointVisionTiles)...min(rows - 1, origin.row + controlPointVisionTiles) {
                for col in max(0, origin.col - controlPointVisionTiles)...min(cols - 1, origin.col + controlPointVisionTiles) {
                    let tile = TileCoord(row: row, col: col)
                    if hypot(CGFloat(row - origin.row), CGFloat(col - origin.col)) <= CGFloat(controlPointVisionTiles) {
                        visible.insert(tile)
                    }
                }
            }
        }
        for (tile, expiry) in supportRevealTiles where expiry > lastUpdateTime {
            visible.insert(tile)
        }

        visibleTiles = visible
        exploredTiles.formUnion(visible)

        for (tile, fog) in fogNodes {
            if visibleTiles.contains(tile) {
                fog.alpha = 0
            } else if exploredTiles.contains(tile) {
                fog.alpha = 0.48
            } else {
                fog.alpha = 0.86
            }
        }

        for entity in entities.values where entity.faction == .enemy {
            entity.node.isHidden = !isKnownToFaction(entity, observer: .player)
        }
    }

    private func isVisible(point: CGPoint) -> Bool {
        guard let tile = tile(at: point) else { return false }
        return visibleTiles.contains(tile)
    }

    private func isKnownToFaction(_ target: GameEntity, observer: Faction) -> Bool {
        if target.faction == observer || target.faction == .neutral {
            return true
        }
        if observer == .player && !isVisible(point: target.node.position) {
            return false
        }
        if target.kind == .submarine {
            return isSubmarineDetected(target, by: observer)
        }
        return true
    }

    private func isSubmarineDetected(_ submarine: GameEntity, by observer: Faction) -> Bool {
        guard submarine.kind == .submarine else { return true }
        if submarine.revealedUntil > lastUpdateTime {
            return true
        }
        return entities.values.contains { sensor in
            sensor.faction == observer &&
            sensor.isAlive &&
            (!sensor.kind.isStructure || sensor.isOperational) &&
            sensor.kind.hasSonar &&
            sensor.node.position.distance(to: submarine.node.position) <= sonarRange(for: sensor.kind)
        }
    }

    private func sonarRange(for kind: EntityKind) -> CGFloat {
        switch kind {
        case .submarine:
            250
        case .battleship:
            230
        case .carrier:
            210
        case .helicopter:
            185
        case .sonarBuoy:
            340
        default:
            0
        }
    }

    private func refreshSelection() {
        for entity in entities.values {
            entity.selectionNode.isHidden = !selectedIDs.contains(entity.id)
            entity.rallyNode.isHidden = !(selectedIDs.contains(entity.id) && entity.kind.supportsRallyPoint && entity.rallyPoint != nil)
            entity.sonarCoverageNode.isHidden = !shouldShowSonarCoverage(for: entity)
            entity.escortCoverageNode.isHidden = !shouldShowHighValueNavalEscortCoverage(for: entity)
            entity.navalGunRangeNode.isHidden = !shouldShowNavalGunRange(for: entity)
            entity.repairCoverageNode.isHidden = !shouldShowMechanicRepairCoverage(for: entity)
            entity.carrierGuardAnchorCoverageNode.isHidden = !shouldShowCarrierGuardAnchorCoverage(for: entity)
            if !selectedIDs.contains(entity.id) {
                entity.commandIntentNode.isHidden = true
                entity.commandIntentNode.removeAllChildren()
            }
        }
        let selected = selectedIDs.compactMap { entities[$0] }.filter { $0.isAlive }
        refreshCommandIntentVisuals(for: selected)
        refreshFocusFireMarker(for: selected)
    }

    private func refreshAirDefenseThreatVisuals(for selected: [GameEntity]) {
        let selectedAir = selected.filter {
            $0.faction == .player && $0.isAlive && $0.kind.domain == .air
        }
        let threatIDs = Set(activeKnownAirDefenseThreats(for: selectedAir).map(\.id))
        for entity in entities.values {
            let show = threatIDs.contains(entity.id)
            entity.airDefenseThreatCoverageNode.isHidden = !show
            entity.airDefenseThreatMarkerNode.isHidden = !show
        }
    }

    private func shouldShowSonarCoverage(for entity: GameEntity) -> Bool {
        selectedIDs.contains(entity.id) &&
            entity.faction == .player &&
            isActiveSonarSensor(entity)
    }

    private func shouldShowHighValueNavalEscortCoverage(for entity: GameEntity) -> Bool {
        selectedIDs.contains(entity.id) &&
            entity.faction == .player &&
            entity.isAlive &&
            entity.isOperational &&
            !entity.kind.isStructure &&
            highValueNavalEscortRequirement(for: entity.kind) != nil
    }

    private func shouldShowNavalGunRange(for entity: GameEntity) -> Bool {
        selectedIDs.contains(entity.id) &&
            entity.faction == .player &&
            entity.isAlive &&
            entity.isOperational &&
            (entity.kind == .battleship || entity.kind == .coastalBattery)
    }

    private func shouldShowMechanicRepairCoverage(for entity: GameEntity) -> Bool {
        selectedIDs.contains(entity.id) &&
            entity.faction == .player &&
            entity.isAlive &&
            entity.kind == .mechanic
    }

    private func shouldShowCarrierGuardAnchorCoverage(for entity: GameEntity) -> Bool {
        guard entity.faction == .player,
              entity.kind == .carrier,
              entity.isAlive
        else { return false }

        if selectedIDs.contains(entity.id),
           entity.holdPosition != nil {
            return true
        }

        return selectedIDs.compactMap { entities[$0] }.contains { wing in
            wing.faction == .player &&
                wing.isAlive &&
                (wing.kind == .helicopter || wing.kind == .fighter) &&
                carrierGuardAnchor(for: wing)?.id == entity.id
        }
    }

    private func sharedFocusFireTarget(for selected: [GameEntity]) -> (target: GameEntity, count: Int)? {
        let attackers = selected.filter {
            $0.faction == .player &&
            $0.isAlive &&
            !$0.kind.isStructure
        }
        var counts: [Int: (target: GameEntity, count: Int)] = [:]
        for unit in attackers {
            guard let target = unit.attackTarget,
                  target.isAlive,
                  isKnownToFaction(target, observer: .player)
            else { continue }
            if var entry = counts[target.id] {
                entry.count += 1
                counts[target.id] = entry
            } else {
                counts[target.id] = (target, 1)
            }
        }
        guard let focus = counts.values.max(by: { left, right in
            if left.count == right.count {
                return left.target.id > right.target.id
            }
            return left.count < right.count
        }), focus.count >= 2 else {
            return nil
        }
        return focus
    }

    private func focusFireSummaryLine(for selected: [GameEntity]) -> String? {
        guard let focus = sharedFocusFireTarget(for: selected) else { return nil }
        return "FOCUS \(focus.count) Tgt \(focus.target.kind.shortCode)"
    }

    private func refreshFocusFireMarker(for selected: [GameEntity]) {
        focusFireMarkerNode.removeAllChildren()

        guard let focus = sharedFocusFireTarget(for: selected) else {
            focusFireMarkerNode.isHidden = true
            return
        }

        let target = focus.target
        let color = UIColor(red: 1.0, green: 0.28, blue: 0.22, alpha: 1.0)
        let footprint = max(28, target.kind.footprint)
        focusFireMarkerNode.position = target.node.position
        focusFireMarkerNode.zPosition = 20

        let outer = SKShapeNode(ellipseOf: CGSize(width: footprint * 1.9, height: footprint * 1.05))
        outer.strokeColor = color
        outer.fillColor = color.withAlphaComponent(0.08)
        outer.lineWidth = 2.5
        outer.glowWidth = 1.2
        focusFireMarkerNode.addChild(outer)

        let inner = SKShapeNode(ellipseOf: CGSize(width: footprint * 1.15, height: footprint * 0.62))
        inner.strokeColor = color.withAlphaComponent(0.85)
        inner.fillColor = .clear
        inner.lineWidth = 1.6
        focusFireMarkerNode.addChild(inner)

        let cross = CGMutablePath()
        let armX = footprint * 0.95
        let armY = footprint * 0.55
        cross.move(to: CGPoint(x: -armX, y: 0))
        cross.addLine(to: CGPoint(x: armX, y: 0))
        cross.move(to: CGPoint(x: 0, y: -armY))
        cross.addLine(to: CGPoint(x: 0, y: armY))
        let crossNode = SKShapeNode(path: cross)
        crossNode.strokeColor = color
        crossNode.lineWidth = 2.2
        crossNode.lineCap = .round
        focusFireMarkerNode.addChild(crossNode)

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "FOCUS \(focus.count)"
        label.fontSize = 11
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: footprint * 0.72 + 12)
        focusFireMarkerNode.addChild(label)

        focusFireMarkerNode.isHidden = false
    }

    private func refreshCommandIntentVisuals(for selected: [GameEntity]) {
        let selectedMobileIDs = Set(
            selected
                .filter { $0.faction == .player && $0.isAlive && !$0.kind.isStructure }
                .map(\.id)
        )
        for entity in entities.values {
            guard selectedMobileIDs.contains(entity.id) else {
                entity.commandIntentNode.isHidden = true
                entity.commandIntentNode.removeAllChildren()
                continue
            }
            updateCommandIntentMarker(for: entity)
        }
    }

    private func updateCommandIntentMarker(for entity: GameEntity) {
        entity.commandIntentNode.removeAllChildren()

        enum IntentKind {
            case attack
            case attackMove
            case move
            case hold
        }

        let intent: (kind: IntentKind, point: CGPoint)?
        if let target = entity.attackTarget,
           target.isAlive,
           isKnownToFaction(target, observer: .player) {
            intent = (.attack, target.node.position)
        } else if let attackMoveDestination = entity.attackMoveDestination {
            intent = (.attackMove, attackMoveDestination)
        } else if let destination = entity.destination {
            intent = (.move, destination)
        } else if let pathEnd = entity.path.last {
            intent = (.move, pathEnd)
        } else if let holdPosition = entity.holdPosition {
            intent = (.hold, holdPosition)
        } else {
            intent = nil
        }

        guard let intent else {
            entity.commandIntentNode.isHidden = true
            return
        }

        let color: UIColor
        let lineWidth: CGFloat
        let dash: [CGFloat]?
        switch intent.kind {
        case .attack:
            color = UIColor(red: 1.0, green: 0.30, blue: 0.20, alpha: 1.0)
            lineWidth = 2.4
            dash = [7, 5]
        case .attackMove:
            color = UIColor(red: 1.0, green: 0.58, blue: 0.20, alpha: 1.0)
            lineWidth = 2.3
            dash = [8, 4]
        case .move:
            color = UIColor(red: 0.24, green: 1.0, blue: 0.62, alpha: 1.0)
            lineWidth = 2.1
            dash = [6, 5]
        case .hold:
            color = UIColor(red: 1.0, green: 0.86, blue: 0.34, alpha: 1.0)
            lineWidth = 1.8
            dash = [3, 4]
        }

        let localPoint = intent.point - entity.node.position
        let solidPath = CGMutablePath()
        solidPath.move(to: .zero)
        solidPath.addLine(to: localPoint)
        let strokedPath: CGPath
        if let dash {
            strokedPath = solidPath.copy(dashingWithPhase: 0, lengths: dash)
        } else {
            strokedPath = solidPath
        }
        let line = SKShapeNode(path: strokedPath)
        line.strokeColor = color.withAlphaComponent(0.88)
        line.lineWidth = lineWidth
        line.glowWidth = 0.8
        line.lineCap = .round
        entity.commandIntentNode.addChild(line)

        let tip = SKShapeNode(ellipseOf: CGSize(width: intent.kind == .attack ? 18 : 14, height: intent.kind == .attack ? 12 : 9))
        tip.position = localPoint
        tip.fillColor = color.withAlphaComponent(0.14)
        tip.strokeColor = color
        tip.lineWidth = 2
        tip.glowWidth = 0.6
        entity.commandIntentNode.addChild(tip)

        if intent.kind == .attack {
            let cross = CGMutablePath()
            cross.move(to: CGPoint(x: localPoint.x - 6, y: localPoint.y))
            cross.addLine(to: CGPoint(x: localPoint.x + 6, y: localPoint.y))
            cross.move(to: CGPoint(x: localPoint.x, y: localPoint.y - 5))
            cross.addLine(to: CGPoint(x: localPoint.x, y: localPoint.y + 5))
            let crossNode = SKShapeNode(path: cross)
            crossNode.strokeColor = color
            crossNode.lineWidth = 1.8
            crossNode.lineCap = .round
            entity.commandIntentNode.addChild(crossNode)
        }

        entity.commandIntentNode.isHidden = false
    }

    private func configureSonarCoverageNode(for entity: GameEntity) {
        let range = sonarRange(for: entity.kind)
        guard range > 0 else {
            entity.sonarCoverageNode.isHidden = true
            return
        }

        entity.sonarCoverageNode.path = CGPath(
            ellipseIn: CGRect(x: -range, y: -range, width: range * 2, height: range * 2),
            transform: nil
        )
        entity.sonarCoverageNode.fillColor = UIColor(red: 0.22, green: 0.88, blue: 1.0, alpha: 0.035)
        entity.sonarCoverageNode.strokeColor = UIColor(red: 0.32, green: 0.92, blue: 1.0, alpha: 0.42)
        entity.sonarCoverageNode.lineWidth = 2
        entity.sonarCoverageNode.glowWidth = 1.2
        entity.sonarCoverageNode.zPosition = -4
        entity.sonarCoverageNode.isHidden = true
    }

    private func configureEscortCoverageNode(for entity: GameEntity) {
        guard highValueNavalEscortRequirement(for: entity.kind) != nil else {
            entity.escortCoverageNode.isHidden = true
            return
        }

        let range = highValueNavalEscortRadius
        entity.escortCoverageNode.path = CGPath(
            ellipseIn: CGRect(x: -range, y: -range, width: range * 2, height: range * 2),
            transform: nil
        )
        entity.escortCoverageNode.fillColor = UIColor(red: 1.0, green: 0.74, blue: 0.24, alpha: 0.025)
        entity.escortCoverageNode.strokeColor = UIColor(red: 1.0, green: 0.78, blue: 0.30, alpha: 0.34)
        entity.escortCoverageNode.lineWidth = 2
        entity.escortCoverageNode.glowWidth = 1.0
        entity.escortCoverageNode.zPosition = -5
        entity.escortCoverageNode.isHidden = true
    }

    private func configureNavalGunRangeNode(for entity: GameEntity) {
        guard entity.kind == .battleship || entity.kind == .coastalBattery else {
            entity.navalGunRangeNode.isHidden = true
            return
        }

        let range = entity.kind.attackRange
        // isometric-friendly ellipse: full horizontal range, compressed vertical
        let width = range * 2
        let height = range * 1.05
        entity.navalGunRangeNode.path = CGPath(
            ellipseIn: CGRect(x: -width * 0.5, y: -height * 0.5, width: width, height: height),
            transform: nil
        )
        entity.navalGunRangeNode.fillColor = UIColor(red: 1.0, green: 0.55, blue: 0.18, alpha: 0.03)
        entity.navalGunRangeNode.strokeColor = UIColor(red: 1.0, green: 0.62, blue: 0.22, alpha: 0.58)
        entity.navalGunRangeNode.lineWidth = entity.kind == .battleship ? 2.6 : 2.2
        entity.navalGunRangeNode.glowWidth = 1.1
        entity.navalGunRangeNode.zPosition = -6
        entity.navalGunRangeNode.isHidden = true
    }

    private func configureRepairCoverageNode(for entity: GameEntity) {
        guard entity.kind == .mechanic else {
            entity.repairCoverageNode.isHidden = true
            return
        }

        let range = mechanicRepairRange
        entity.repairCoverageNode.path = CGPath(
            ellipseIn: CGRect(x: -range, y: -range, width: range * 2, height: range * 2),
            transform: nil
        )
        entity.repairCoverageNode.fillColor = UIColor(red: 0.24, green: 1.0, blue: 0.54, alpha: 0.032)
        entity.repairCoverageNode.strokeColor = UIColor(red: 0.38, green: 1.0, blue: 0.62, alpha: 0.40)
        entity.repairCoverageNode.lineWidth = 2
        entity.repairCoverageNode.glowWidth = 1.0
        entity.repairCoverageNode.zPosition = -4
        entity.repairCoverageNode.isHidden = true
    }

    private func configureCarrierGuardAnchorCoverageNode(for entity: GameEntity) {
        guard entity.kind == .carrier else {
            entity.carrierGuardAnchorCoverageNode.isHidden = true
            return
        }

        let range = carrierGuardThreatRadius
        entity.carrierGuardAnchorCoverageNode.path = CGPath(
            ellipseIn: CGRect(x: -range, y: -range, width: range * 2, height: range * 2),
            transform: nil
        )
        entity.carrierGuardAnchorCoverageNode.fillColor = UIColor(red: 0.46, green: 0.95, blue: 1.0, alpha: 0.025)
        entity.carrierGuardAnchorCoverageNode.strokeColor = UIColor(red: 0.46, green: 0.95, blue: 1.0, alpha: 0.38)
        entity.carrierGuardAnchorCoverageNode.lineWidth = 2
        entity.carrierGuardAnchorCoverageNode.glowWidth = 1.0
        entity.carrierGuardAnchorCoverageNode.zPosition = -4.5
        entity.carrierGuardAnchorCoverageNode.isHidden = true
    }

    private func configureAirDefenseThreatNodes(for entity: GameEntity) {
        guard entity.kind == .samSite || entity.kind == .aaTruck else {
            entity.airDefenseThreatCoverageNode.isHidden = true
            entity.airDefenseThreatMarkerNode.isHidden = true
            return
        }

        let range = entity.kind.attackRange
        entity.airDefenseThreatCoverageNode.path = CGPath(
            ellipseIn: CGRect(x: -range, y: -range, width: range * 2, height: range * 2),
            transform: nil
        )
        entity.airDefenseThreatCoverageNode.fillColor = UIColor(red: 1.0, green: 0.22, blue: 0.12, alpha: 0.018)
        entity.airDefenseThreatCoverageNode.strokeColor = UIColor(red: 1.0, green: 0.36, blue: 0.16, alpha: 0.56)
        entity.airDefenseThreatCoverageNode.lineWidth = entity.kind == .samSite ? 2.8 : 2.2
        entity.airDefenseThreatCoverageNode.glowWidth = 1.4
        entity.airDefenseThreatCoverageNode.zPosition = -7
        entity.airDefenseThreatCoverageNode.isHidden = true

        let markerColor = UIColor(red: 1.0, green: 0.52, blue: 0.16, alpha: 1.0)
        let markerBaseY = entity.kind.footprint * 0.52 + 34
        for index in 0..<3 {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -8, y: 4))
            path.addLine(to: CGPoint(x: 0, y: -4))
            path.addLine(to: CGPoint(x: 8, y: 4))
            let chevron = SKShapeNode(path: path)
            chevron.position = CGPoint(x: 0, y: markerBaseY + CGFloat(index) * 9)
            chevron.strokeColor = markerColor.withAlphaComponent(1.0 - CGFloat(index) * 0.18)
            chevron.lineWidth = 3
            chevron.lineCap = .round
            chevron.lineJoin = .round
            chevron.glowWidth = 1
            entity.airDefenseThreatMarkerNode.addChild(chevron)
        }
        let core = SKShapeNode(circleOfRadius: 4)
        core.position = CGPoint(x: 0, y: markerBaseY - 10)
        core.fillColor = UIColor(red: 1.0, green: 0.24, blue: 0.14, alpha: 1.0)
        core.strokeColor = UIColor.white.withAlphaComponent(0.92)
        core.lineWidth = 1.2
        entity.airDefenseThreatMarkerNode.addChild(core)
        entity.airDefenseThreatMarkerNode.zPosition = 32
        entity.airDefenseThreatMarkerNode.isHidden = true
    }

    private func showMessage(_ text: String, color: UIColor) {
        messageLabel.text = text
        messageLabel.fontColor = color
        messageLabel.removeAllActions()
        messageLabel.alpha = 1
        messageLabel.run(.sequence([.wait(forDuration: 3.2), .fadeAlpha(to: victoryState == nil ? 0.25 : 1, duration: 0.45)]))
    }

    private func showMoveMarker(at point: CGPoint, persistent: Bool = false) {
        let color = UIColor(red: 0.24, green: 1.0, blue: 0.62, alpha: 1.0)
        let node = SKNode()
        node.position = point
        node.zPosition = 264

        let ring = SKShapeNode(ellipseOf: CGSize(width: 50, height: 24))
        ring.strokeColor = color
        ring.fillColor = color.withAlphaComponent(0.12)
        ring.lineWidth = 3
        ring.glowWidth = 1.5
        node.addChild(ring)

        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: -13, y: 0))
        arrowPath.addLine(to: CGPoint(x: 8, y: 0))
        arrowPath.move(to: CGPoint(x: 1, y: 7))
        arrowPath.addLine(to: CGPoint(x: 9, y: 0))
        arrowPath.addLine(to: CGPoint(x: 1, y: -7))
        for side in [-1.0, 1.0] {
            let x = CGFloat(side) * 30
            arrowPath.move(to: CGPoint(x: x, y: -5))
            arrowPath.addLine(to: CGPoint(x: x, y: 5))
        }
        let arrow = SKShapeNode(path: arrowPath)
        arrow.strokeColor = color
        arrow.lineWidth = 3
        arrow.lineCap = .round
        arrow.lineJoin = .round
        node.addChild(arrow)

        let label = commandMarkerLabel(text: "MOVE", color: color, y: 22)
        node.addChild(label)
        presentCommandMarker(node, persistent: persistent, exitScale: 1.28)
    }

    private func showAttackMoveMarker(at point: CGPoint, persistent: Bool = false) {
        let color = UIColor(red: 1.0, green: 0.58, blue: 0.20, alpha: 1.0)
        let node = SKNode()
        node.position = point
        node.zPosition = 266

        let ring = SKShapeNode(ellipseOf: CGSize(width: 62, height: 30))
        ring.strokeColor = color
        ring.fillColor = color.withAlphaComponent(0.14)
        ring.lineWidth = 3
        ring.glowWidth = 2
        node.addChild(ring)

        let innerRing = SKShapeNode(ellipseOf: CGSize(width: 38, height: 18))
        innerRing.strokeColor = color.withAlphaComponent(0.78)
        innerRing.fillColor = .clear
        innerRing.lineWidth = 2
        node.addChild(innerRing)

        let crossPath = CGMutablePath()
        crossPath.move(to: CGPoint(x: -18, y: 0))
        crossPath.addLine(to: CGPoint(x: 18, y: 0))
        crossPath.move(to: CGPoint(x: 0, y: -11))
        crossPath.addLine(to: CGPoint(x: 0, y: 11))
        crossPath.move(to: CGPoint(x: 8, y: 7))
        crossPath.addLine(to: CGPoint(x: 18, y: 0))
        crossPath.addLine(to: CGPoint(x: 8, y: -7))
        let cross = SKShapeNode(path: crossPath)
        cross.strokeColor = color
        cross.lineWidth = 3
        cross.lineCap = .round
        cross.lineJoin = .round
        node.addChild(cross)

        let label = commandMarkerLabel(text: "AMOV", color: color, y: 26)
        node.addChild(label)
        presentCommandMarker(node, persistent: persistent, exitScale: 1.24)
    }

    private func showAttackTargetMarker(at point: CGPoint, footprint: CGFloat, label: String, persistent: Bool = false) {
        let color = UIColor(red: 1.0, green: 0.30, blue: 0.20, alpha: 1.0)
        let width = max(64, min(112, footprint * 1.55))
        let height = max(34, width * 0.52)
        let halfWidth = width * 0.5
        let halfHeight = height * 0.5
        let cornerLength = min(18, width * 0.22)
        let node = SKNode()
        node.position = point
        node.zPosition = 268

        let ring = SKShapeNode(ellipseOf: CGSize(width: width * 0.82, height: height * 0.72))
        ring.strokeColor = color.withAlphaComponent(0.82)
        ring.fillColor = color.withAlphaComponent(0.08)
        ring.lineWidth = 2
        ring.glowWidth = 1.5
        node.addChild(ring)

        let bracketPath = CGMutablePath()
        for xSide in [-1.0, 1.0] {
            for ySide in [-1.0, 1.0] {
                let x = CGFloat(xSide) * halfWidth
                let y = CGFloat(ySide) * halfHeight
                bracketPath.move(to: CGPoint(x: x - CGFloat(xSide) * cornerLength, y: y))
                bracketPath.addLine(to: CGPoint(x: x, y: y))
                bracketPath.addLine(to: CGPoint(x: x, y: y - CGFloat(ySide) * cornerLength * 0.65))
            }
        }
        let brackets = SKShapeNode(path: bracketPath)
        brackets.strokeColor = color
        brackets.lineWidth = 4
        brackets.lineCap = .square
        brackets.lineJoin = .round
        node.addChild(brackets)

        let dot = SKShapeNode(circleOfRadius: 3.5)
        dot.fillColor = color
        dot.strokeColor = .white
        dot.lineWidth = 1
        node.addChild(dot)

        let labelNode = commandMarkerLabel(text: "ATK \(label)", color: color, y: halfHeight + 11)
        node.addChild(labelNode)
        presentCommandMarker(node, persistent: persistent, exitScale: 1.16)
    }

    private func commandMarkerLabel(text: String, color: UIColor, y: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = text
        label.fontSize = 11
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: y)
        return label
    }

    private func presentCommandMarker(_ node: SKNode, persistent: Bool, exitScale: CGFloat) {
        effectsLayer.addChild(node)
        guard !persistent else { return }

        node.alpha = 0.25
        node.setScale(0.78)
        node.run(.sequence([
            .group([
                .fadeAlpha(to: 1.0, duration: 0.08),
                .scale(to: 1.0, duration: 0.08)
            ]),
            .wait(forDuration: 0.18),
            .group([
                .scale(to: exitScale, duration: 0.42),
                .fadeOut(withDuration: 0.42)
            ]),
            .removeFromParent()
        ]))
    }

    private func showObjectiveTargetMarker(at point: CGPoint, label: String) {
        let color = UIColor(red: 1.0, green: 0.78, blue: 0.25, alpha: 1.0)
        let node = SKNode()
        node.position = point
        node.zPosition = 266

        let ring = SKShapeNode(ellipseOf: CGSize(width: 74, height: 34))
        ring.fillColor = color.withAlphaComponent(0.10)
        ring.strokeColor = color
        ring.lineWidth = 3
        ring.glowWidth = 2
        node.addChild(ring)

        let bracketPath = CGMutablePath()
        bracketPath.move(to: CGPoint(x: -25, y: 0))
        bracketPath.addLine(to: CGPoint(x: -12, y: 0))
        bracketPath.move(to: CGPoint(x: 12, y: 0))
        bracketPath.addLine(to: CGPoint(x: 25, y: 0))
        bracketPath.move(to: CGPoint(x: 0, y: -14))
        bracketPath.addLine(to: CGPoint(x: 0, y: -5))
        bracketPath.move(to: CGPoint(x: 0, y: 5))
        bracketPath.addLine(to: CGPoint(x: 0, y: 14))
        let bracket = SKShapeNode(path: bracketPath)
        bracket.strokeColor = color
        bracket.lineWidth = 3
        bracket.lineCap = .round
        node.addChild(bracket)

        let labelNode = SKLabelNode(fontNamed: "Menlo-Bold")
        labelNode.text = label
        labelNode.fontSize = 14
        labelNode.fontColor = color
        labelNode.verticalAlignmentMode = .center
        labelNode.position = CGPoint(x: 0, y: 30)
        node.addChild(labelNode)

        effectsLayer.addChild(node)
        node.run(.sequence([.group([.scale(to: 1.18, duration: 0.65), .fadeOut(withDuration: 0.65)]), .removeFromParent()]))
    }

    private func showDeniedMarker(at point: CGPoint, reason: String) {
        let color = UIColor(red: 1.0, green: 0.30, blue: 0.18, alpha: 1.0)
        let node = SKNode()
        node.position = point
        node.zPosition = 268

        let ring = SKShapeNode(ellipseOf: CGSize(width: 54, height: 25))
        ring.fillColor = color.withAlphaComponent(0.10)
        ring.strokeColor = color
        ring.lineWidth = 3
        ring.glowWidth = 1.5
        node.addChild(ring)

        let crossPath = CGMutablePath()
        crossPath.move(to: CGPoint(x: -14, y: -10))
        crossPath.addLine(to: CGPoint(x: 14, y: 10))
        crossPath.move(to: CGPoint(x: -14, y: 10))
        crossPath.addLine(to: CGPoint(x: 14, y: -10))

        let cross = SKShapeNode(path: crossPath)
        cross.strokeColor = color
        cross.lineWidth = 3
        cross.lineCap = .round
        node.addChild(cross)

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = reason
        label.fontSize = 10
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 27)
        node.addChild(label)

        effectsLayer.addChild(node)
        node.run(.sequence([
            .group([
                .scale(to: 1.35, duration: 0.52),
                .fadeOut(withDuration: 0.52)
            ]),
            .removeFromParent()
        ]))
    }

    private func showHoldMarker(at point: CGPoint) {
        let color = UIColor(red: 0.78, green: 1.0, blue: 0.42, alpha: 1.0)
        let ring = SKShapeNode(ellipseOf: CGSize(width: 96, height: 44))
        ring.position = point
        ring.strokeColor = color
        ring.fillColor = color.withAlphaComponent(0.10)
        ring.lineWidth = 3
        ring.glowWidth = 1.5
        ring.zPosition = 262
        effectsLayer.addChild(ring)
        ring.run(.sequence([.group([.scale(to: 1.55, duration: 0.42), .fadeOut(withDuration: 0.42)]), .removeFromParent()]))

        let chevron = SKShapeNode(path: trianglePath(size: 22))
        chevron.position = point + CGPoint(x: 0, y: 16)
        chevron.zRotation = .pi
        chevron.fillColor = color.withAlphaComponent(0.92)
        chevron.strokeColor = UIColor.black.withAlphaComponent(0.55)
        chevron.lineWidth = 1.5
        chevron.zPosition = 263
        effectsLayer.addChild(chevron)
        chevron.run(.sequence([.group([.moveBy(x: 0, y: 12, duration: 0.42), .fadeOut(withDuration: 0.42)]), .removeFromParent()]))
    }

    private func showUnderAttackPing(at point: CGPoint, kind: EntityKind) {
        let color = UIColor(red: 1.0, green: 0.18, blue: 0.12, alpha: 1.0)
        let size = kind.isStructure ? CGSize(width: 118, height: 56) : CGSize(width: 78, height: 36)
        let ring = SKShapeNode(ellipseOf: size)
        ring.position = point
        ring.strokeColor = color
        ring.fillColor = color.withAlphaComponent(0.10)
        ring.lineWidth = 4
        ring.glowWidth = 2
        ring.zPosition = 286
        effectsLayer.addChild(ring)
        ring.run(.sequence([.group([.scale(to: 1.75, duration: 0.48), .fadeOut(withDuration: 0.48)]), .removeFromParent()]))

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "UNDER ATTACK"
        label.fontSize = 11
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = point + CGPoint(x: 0, y: kind.footprint * 0.65 + 44)
        label.zPosition = 287
        effectsLayer.addChild(label)
        label.run(.sequence([.group([.moveBy(x: 0, y: 16, duration: 0.55), .fadeOut(withDuration: 0.55)]), .removeFromParent()]))

        guard minimapFrame.width > 0 else { return }
        let miniPoint = minimapPoint(forWorldPoint: point)
        let miniPulse = SKShapeNode(circleOfRadius: 7)
        miniPulse.position = miniPoint
        miniPulse.fillColor = color.withAlphaComponent(0.18)
        miniPulse.strokeColor = color
        miniPulse.lineWidth = 2
        miniPulse.zPosition = 25
        hudNode.addChild(miniPulse)
        miniPulse.run(.sequence([.group([.scale(to: 2.4, duration: 0.62), .fadeOut(withDuration: 0.62)]), .removeFromParent()]))
    }

    private func showEnemyDefensePing(at point: CGPoint) {
        let color = UIColor(red: 1.0, green: 0.30, blue: 0.18, alpha: 1.0)
        let ring = SKShapeNode(ellipseOf: CGSize(width: 98, height: 46))
        ring.position = point
        ring.strokeColor = color
        ring.fillColor = color.withAlphaComponent(0.08)
        ring.lineWidth = 3
        ring.glowWidth = 1.5
        ring.zPosition = 284
        effectsLayer.addChild(ring)
        ring.run(.sequence([.group([.scale(to: 1.45, duration: 0.38), .fadeOut(withDuration: 0.38)]), .removeFromParent()]))

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "DEFEND"
        label.fontSize = 10
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = point + CGPoint(x: 0, y: 48)
        label.zPosition = 285
        effectsLayer.addChild(label)
        label.run(.sequence([.group([.moveBy(x: 0, y: 14, duration: 0.45), .fadeOut(withDuration: 0.45)]), .removeFromParent()]))
    }

    private func showConstructionPulse(at point: CGPoint) {
        let ring = SKShapeNode(ellipseOf: CGSize(width: 86, height: 42))
        ring.position = point
        ring.strokeColor = UIColor(red: 0.98, green: 0.84, blue: 0.36, alpha: 1.0)
        ring.fillColor = UIColor(red: 0.98, green: 0.74, blue: 0.22, alpha: 0.16)
        ring.lineWidth = 4
        ring.zPosition = 270
        effectsLayer.addChild(ring)
        ring.run(.sequence([.group([.scale(to: 1.55, duration: 0.45), .fadeOut(withDuration: 0.45)]), .removeFromParent()]))
    }

    private func showSupportPowerEffect(_ power: SupportPower, at point: CGPoint, faction: Faction) {
        let color: UIColor
        let labelText: String
        switch power {
        case .reconSweep:
            color = faction == .enemy
                ? UIColor(red: 1.0, green: 0.38, blue: 0.25, alpha: 1.0)
                : UIColor(red: 0.30, green: 0.92, blue: 1.0, alpha: 1.0)
            labelText = "SCAN"
        case .fieldRepair:
            color = faction == .enemy
                ? UIColor(red: 1.0, green: 0.62, blue: 0.36, alpha: 1.0)
                : UIColor(red: 0.44, green: 1.0, blue: 0.76, alpha: 1.0)
            labelText = "REPAIR"
        case .airStrike:
            color = faction == .enemy
                ? UIColor(red: 1.0, green: 0.42, blue: 0.20, alpha: 1.0)
                : UIColor(red: 1.0, green: 0.74, blue: 0.28, alpha: 1.0)
            labelText = "AIR STRIKE"
        case .navalBarrage:
            color = faction == .enemy
                ? UIColor(red: 1.0, green: 0.32, blue: 0.22, alpha: 1.0)
                : UIColor(red: 0.42, green: 0.92, blue: 1.0, alpha: 1.0)
            labelText = "BARRAGE"
        }

        let ringSize = CGSize(width: power.radius * 1.55, height: power.radius * 0.72)
        for index in 0..<3 {
            let ring = SKShapeNode(ellipseOf: ringSize)
            ring.position = point
            ring.strokeColor = color
            ring.fillColor = color.withAlphaComponent(power == .reconSweep ? 0.05 : 0.10)
            ring.lineWidth = power == .reconSweep ? 2 : 4
            ring.glowWidth = 2
            ring.zPosition = 290 + CGFloat(index)
            effectsLayer.addChild(ring)
            ring.run(.sequence([
                .wait(forDuration: TimeInterval(index) * 0.12),
                .group([.scale(to: 1.35 + CGFloat(index) * 0.18, duration: 0.55), .fadeOut(withDuration: 0.55)]),
                .removeFromParent()
            ]))
        }

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = labelText
        label.fontSize = 12
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = point + CGPoint(x: 0, y: power.radius * 0.38 + 24)
        label.zPosition = 294
        effectsLayer.addChild(label)
        label.run(.sequence([.group([.moveBy(x: 0, y: 18, duration: 0.62), .fadeOut(withDuration: 0.62)]), .removeFromParent()]))

        switch power {
        case .reconSweep:
            showSonarPing(at: point, faction: faction)
        case .fieldRepair:
            for index in 0..<5 {
                let offset = CGPoint(
                    x: CGFloat(index - 2) * 22,
                    y: CGFloat(index % 2 == 0 ? 14 : -12)
                )
                showRepairSpark(at: point + offset)
            }
        case .airStrike:
            let start = faction == .enemy
                ? point + CGPoint(x: 320, y: 210)
                : point + CGPoint(x: -320, y: 210)
            let end = faction == .enemy
                ? point + CGPoint(x: -210, y: -110)
                : point + CGPoint(x: 210, y: -110)
            let plane = SKShapeNode(path: jetPath())
            plane.fillColor = faction == .enemy ? color : UIColor(red: 0.95, green: 0.86, blue: 0.45, alpha: 1.0)
            plane.strokeColor = UIColor(white: 0.12, alpha: 1.0)
            plane.lineWidth = 1.5
            plane.position = start
            plane.setScale(0.78)
            plane.zPosition = 292
            effectsLayer.addChild(plane)
            plane.run(.sequence([.move(to: end, duration: 0.42), .removeFromParent()]))
            showProjectile(from: start, to: point, kind: .fighter)
            explode(at: point, scale: 1.1)
        case .navalBarrage:
            for index in 0..<4 {
                let offset = CGPoint(x: CGFloat(index - 1) * 34, y: CGFloat((index % 2) - 1) * 18)
                let start = point + CGPoint(x: 320, y: CGFloat(index) * 26 - 120)
                let impact = point + offset
                showProjectile(from: start, to: impact, kind: .battleship)
                let impactNode = SKShapeNode(ellipseOf: CGSize(width: 34, height: 16))
                impactNode.position = impact
                impactNode.fillColor = color.withAlphaComponent(0.16)
                impactNode.strokeColor = color
                impactNode.lineWidth = 2
                impactNode.zPosition = 291
                effectsLayer.addChild(impactNode)
                impactNode.run(.sequence([
                    .wait(forDuration: TimeInterval(index) * 0.08),
                    .group([.scale(to: 1.9, duration: 0.36), .fadeOut(withDuration: 0.36)]),
                    .removeFromParent()
                ]))
            }
            explode(at: point, scale: 0.95)
        }
    }

    private func showProductionReady(at point: CGPoint, faction: Faction, kind: EntityKind) {
        let color = faction == .enemy
            ? UIColor(red: 1.0, green: 0.38, blue: 0.28, alpha: 1.0)
            : UIColor(red: 0.30, green: 1.0, blue: 0.78, alpha: 1.0)
        let ring = SKShapeNode(ellipseOf: CGSize(width: 64, height: 30))
        ring.position = point
        ring.strokeColor = color
        ring.fillColor = color.withAlphaComponent(0.12)
        ring.lineWidth = 3
        ring.zPosition = 276
        effectsLayer.addChild(ring)
        ring.run(.sequence([.group([.scale(to: 1.7, duration: 0.36), .fadeOut(withDuration: 0.36)]), .removeFromParent()]))

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "\(kind.shortCode) READY"
        label.fontSize = 11
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = point + CGPoint(x: 0, y: 48)
        label.zPosition = 277
        effectsLayer.addChild(label)
        label.run(.sequence([.group([.moveBy(x: 0, y: 18, duration: 0.55), .fadeOut(withDuration: 0.55)]), .removeFromParent()]))
    }

    private func showProjectile(from start: CGPoint, to end: CGPoint, kind: EntityKind) {
        if kind == .fighter || kind == .samSite || kind == .aaTruck {
            showGuidedMissileTrail(from: start, to: end, kind: kind)
            return
        }

        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        let tracer = SKShapeNode(path: path)
        tracer.strokeColor = projectileColor(for: kind)
        tracer.lineWidth = kind == .battleship || kind == .artillery || kind == .coastalBattery || kind == .samSite ? 4 : 2
        tracer.glowWidth = 2
        tracer.zPosition = 250
        effectsLayer.addChild(tracer)
        tracer.run(.sequence([.fadeOut(withDuration: 0.16), .removeFromParent()]))
    }

    private func showGuidedMissileTrail(
        from start: CGPoint,
        to end: CGPoint,
        kind: EntityKind,
        persistent: Bool = false
    ) {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)

        let smoke = SKShapeNode(path: path)
        smoke.strokeColor = UIColor(white: 0.88, alpha: 0.34)
        smoke.lineWidth = kind == .samSite ? 7 : 5
        smoke.lineCap = .round
        smoke.zPosition = 282
        effectsLayer.addChild(smoke)

        let trail = SKShapeNode(path: path)
        trail.strokeColor = projectileColor(for: kind).withAlphaComponent(0.92)
        trail.lineWidth = kind == .samSite ? 3.5 : 2.5
        trail.glowWidth = 3
        trail.zPosition = 283
        effectsLayer.addChild(trail)

        let missile = SKShapeNode(rectOf: CGSize(width: 18, height: 5), cornerRadius: 2)
        missile.position = persistent
            ? CGPoint(x: (start.x + end.x) * 0.5, y: (start.y + end.y) * 0.5)
            : start
        missile.zRotation = atan2(end.y - start.y, end.x - start.x)
        missile.fillColor = UIColor.white
        missile.strokeColor = projectileColor(for: kind)
        missile.lineWidth = 1.5
        missile.glowWidth = 2
        missile.zPosition = 284
        effectsLayer.addChild(missile)

        guard !persistent else { return }
        smoke.run(.sequence([.fadeOut(withDuration: 0.38), .removeFromParent()]))
        trail.run(.sequence([.fadeOut(withDuration: 0.30), .removeFromParent()]))
        missile.run(.sequence([
            .group([.move(to: end, duration: 0.26), .fadeOut(withDuration: 0.26)]),
            .removeFromParent()
        ]))
    }

    private func shouldShowDamageFloater(for target: GameEntity) -> Bool {
        target.faction == .player || isKnownToFaction(target, observer: .player)
    }

    private func showDamageFloater(at point: CGPoint, amount: CGFloat, faction: Faction, persistent: Bool = false) {
        let value = max(1, Int(amount.rounded()))
        let node = SKNode()
        node.position = point + CGPoint(x: CGFloat((Int(point.x) + Int(point.y)) % 17) - 8, y: 18)
        node.zPosition = 280

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "-\(value)"
        label.fontSize = 13
        label.fontColor = faction == .player
            ? UIColor(red: 1.0, green: 0.82, blue: 0.30, alpha: 1.0)
            : UIColor(red: 1.0, green: 0.42, blue: 0.28, alpha: 1.0)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 1
        node.addChild(label)

        let shadow = SKLabelNode(fontNamed: "Menlo-Bold")
        shadow.text = label.text
        shadow.fontSize = 13
        shadow.fontColor = UIColor.black.withAlphaComponent(0.55)
        shadow.verticalAlignmentMode = .center
        shadow.horizontalAlignmentMode = .center
        shadow.position = CGPoint(x: 1, y: -1)
        shadow.zPosition = 0
        node.addChild(shadow)

        effectsLayer.addChild(node)
        guard !persistent else { return }
        node.alpha = 0.2
        node.setScale(0.82)
        node.run(.sequence([
            .group([
                .fadeAlpha(to: 1.0, duration: 0.06),
                .scale(to: 1.08, duration: 0.08),
                .moveBy(x: 0, y: 10, duration: 0.08)
            ]),
            .group([
                .moveBy(x: 0, y: 28, duration: 0.55),
                .fadeOut(withDuration: 0.55)
            ]),
            .removeFromParent()
        ]))
    }

    private func showAirMissileImpact(
        at point: CGPoint,
        faction: Faction,
        persistent: Bool = false
    ) {
        guard faction == .player || isVisible(point: point) else { return }
        let node = SKNode()
        node.position = point
        node.zPosition = 286

        let color = faction == .enemy
            ? UIColor(red: 1.0, green: 0.42, blue: 0.24, alpha: 1.0)
            : UIColor(red: 1.0, green: 0.82, blue: 0.28, alpha: 1.0)
        for size in [22.0, 38.0] {
            let ring = SKShapeNode(circleOfRadius: CGFloat(size) * 0.5)
            ring.fillColor = color.withAlphaComponent(0.10)
            ring.strokeColor = color.withAlphaComponent(0.94)
            ring.lineWidth = size < 30 ? 3 : 2
            ring.glowWidth = 2
            node.addChild(ring)
        }

        for index in 0..<6 {
            let angle = CGFloat(index) * .pi / 3
            let spark = SKShapeNode(rectOf: CGSize(width: 16, height: 2.5), cornerRadius: 1)
            spark.position = CGPoint(x: cos(angle) * 17, y: sin(angle) * 17)
            spark.zRotation = angle
            spark.fillColor = index.isMultiple(of: 2) ? UIColor.white : color
            spark.strokeColor = .clear
            node.addChild(spark)
        }
        effectsLayer.addChild(node)
        guard !persistent else { return }

        for (index, child) in node.children.enumerated() {
            child.run(.sequence([
                .wait(forDuration: TimeInterval(index) * 0.015),
                .group([.scale(to: 1.55, duration: 0.30), .fadeOut(withDuration: 0.30)])
            ]))
        }
        node.run(.sequence([.wait(forDuration: 0.42), .removeFromParent()]))
    }

    private func projectileColor(for kind: EntityKind) -> UIColor {
        switch kind {
        case .samSite:
            UIColor(red: 0.72, green: 0.95, blue: 1.0, alpha: 1.0)
        case .fighter, .helicopter, .carrier:
            UIColor(red: 1.0, green: 0.74, blue: 0.24, alpha: 1.0)
        case .submarine:
            UIColor(red: 0.30, green: 0.95, blue: 1.0, alpha: 1.0)
        default:
            UIColor(red: 1.0, green: 0.35, blue: 0.20, alpha: 1.0)
        }
    }

    private func launchCarrierWing(from start: CGPoint, to end: CGPoint, faction: Faction) {
        showCarrierDeckPulse(at: start, faction: faction, label: "CV STRIKE")
        showCarrierCraftFlight(kind: .fighter, from: start + CGPoint(x: 0, y: 20), to: end + CGPoint(x: 0, y: 18), faction: faction, duration: 0.34, scale: 0.62)
        showProjectile(from: start, to: end, kind: .carrier)
    }

    private func showCarrierLaunch(from start: CGPoint, to end: CGPoint, faction: Faction, kind: EntityKind) {
        let wakeColor = carrierLaunchColor(for: faction)
        let label = kind == .helicopter ? "CV HLO LAUNCH" : "CV \(kind.shortCode) LAUNCH"

        showCarrierDeckPulse(at: start, faction: faction, label: label)

        let catapultStart = start + CGPoint(x: -8, y: 15)
        let catapultEnd = end + CGPoint(x: 0, y: 12)
        let catapult = SKShapeNode(rectOf: CGSize(width: 58, height: 4), cornerRadius: 1)
        catapult.position = catapultStart
        catapult.fillColor = wakeColor.withAlphaComponent(0.82)
        catapult.strokeColor = .clear
        catapult.zRotation = 0.18
        catapult.zPosition = 276
        effectsLayer.addChild(catapult)
        catapult.run(.sequence([.group([.move(to: catapultEnd, duration: 0.30), .fadeOut(withDuration: 0.30)]), .removeFromParent()]))

        showCarrierLaunchTrail(from: catapultStart, to: catapultEnd, faction: faction)
        showCarrierCraftFlight(kind: kind, from: start + CGPoint(x: -10, y: 22), to: end + CGPoint(x: 0, y: 24), faction: faction, duration: 0.38, scale: kind == .helicopter ? 0.78 : 0.60)
    }

    private func carrierLaunchColor(for faction: Faction) -> UIColor {
        faction == .enemy
            ? UIColor(red: 1.0, green: 0.44, blue: 0.30, alpha: 1.0)
            : UIColor(red: 0.32, green: 0.92, blue: 1.0, alpha: 1.0)
    }

    private func showCarrierDeckPulse(at point: CGPoint, faction: Faction, label: String) {
        let color = carrierLaunchColor(for: faction)

        let deckFlash = SKShapeNode(rectOf: CGSize(width: 76, height: 18), cornerRadius: 2)
        deckFlash.position = point + CGPoint(x: 0, y: 15)
        deckFlash.fillColor = color.withAlphaComponent(0.18)
        deckFlash.strokeColor = color.withAlphaComponent(0.90)
        deckFlash.lineWidth = 2
        deckFlash.zRotation = 0.18
        deckFlash.zPosition = 275
        effectsLayer.addChild(deckFlash)
        deckFlash.run(.sequence([.group([.scale(to: 1.25, duration: 0.26), .fadeOut(withDuration: 0.26)]), .removeFromParent()]))

        let ring = SKShapeNode(ellipseOf: CGSize(width: 76, height: 30))
        ring.position = point
        ring.fillColor = color.withAlphaComponent(0.09)
        ring.strokeColor = color.withAlphaComponent(0.90)
        ring.lineWidth = 2
        ring.zPosition = 274
        effectsLayer.addChild(ring)
        ring.run(.sequence([.group([.scale(to: 1.48, duration: 0.34), .fadeOut(withDuration: 0.34)]), .removeFromParent()]))

        guard faction == .player || isVisible(point: point) else { return }
        let labelNode = SKLabelNode(fontNamed: "Menlo-Bold")
        labelNode.text = label
        labelNode.fontSize = 10
        labelNode.fontColor = color
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        labelNode.position = point + CGPoint(x: 0, y: 50)
        labelNode.zPosition = 278
        effectsLayer.addChild(labelNode)
        labelNode.run(.sequence([.group([.moveBy(x: 0, y: 14, duration: 0.52), .fadeOut(withDuration: 0.52)]), .removeFromParent()]))
    }

    private func showCarrierLaunchTrail(from start: CGPoint, to end: CGPoint, faction: Faction) {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        let trail = SKShapeNode(path: path)
        let color = carrierLaunchColor(for: faction)
        trail.strokeColor = color.withAlphaComponent(0.72)
        trail.lineWidth = 3
        trail.glowWidth = 3
        trail.zPosition = 274
        effectsLayer.addChild(trail)
        trail.run(.sequence([.fadeOut(withDuration: 0.38), .removeFromParent()]))
    }

    private func showCarrierCraftFlight(kind: EntityKind, from start: CGPoint, to end: CGPoint, faction: Faction, duration: TimeInterval, scale: CGFloat) {
        let craft = carrierLaunchCraft(for: kind, faction: faction)
        craft.position = start
        craft.setScale(scale)
        craft.zPosition = 279
        effectsLayer.addChild(craft)
        craft.run(.sequence([.group([.move(to: end, duration: duration), .fadeOut(withDuration: duration)]), .removeFromParent()]))
    }

    private func carrierLaunchCraft(for kind: EntityKind, faction: Faction) -> SKNode {
        let node = SKNode()
        let color = carrierLaunchColor(for: faction)

        if kind == .helicopter {
            let body = SKShapeNode(ellipseOf: CGSize(width: 34, height: 15))
            body.fillColor = color.withAlphaComponent(0.96)
            body.strokeColor = UIColor(white: 0.12, alpha: 1.0)
            body.lineWidth = 1.2
            node.addChild(body)

            let tail = SKShapeNode(rectOf: CGSize(width: 26, height: 4), cornerRadius: 1)
            tail.position = CGPoint(x: -22, y: 0)
            tail.fillColor = color.withAlphaComponent(0.80)
            tail.strokeColor = .clear
            node.addChild(tail)

            let rotor = SKShapeNode(rectOf: CGSize(width: 52, height: 3), cornerRadius: 1)
            rotor.position = CGPoint(x: 1, y: 8)
            rotor.fillColor = UIColor.white.withAlphaComponent(0.82)
            rotor.strokeColor = .clear
            node.addChild(rotor)
        } else {
            let jet = SKShapeNode(path: jetPath())
            jet.fillColor = color.withAlphaComponent(0.96)
            jet.strokeColor = UIColor(white: 0.12, alpha: 1.0)
            jet.lineWidth = 1.3
            node.addChild(jet)
        }

        return node
    }

    private func explode(at point: CGPoint, scale: CGFloat, persistent: Bool = false) {
        let root = SKNode()
        root.position = point
        root.zPosition = 286
        effectsLayer.addChild(root)

        let smoke = SKShapeNode(ellipseOf: CGSize(width: 54 * scale, height: 28 * scale))
        smoke.fillColor = UIColor(white: 0.18, alpha: 0.34)
        smoke.strokeColor = UIColor(white: 0.55, alpha: 0.55)
        smoke.lineWidth = 1.5
        smoke.zPosition = 0
        root.addChild(smoke)

        let fire = SKShapeNode(circleOfRadius: 18 * scale)
        fire.fillColor = UIColor(red: 1.0, green: 0.42, blue: 0.12, alpha: 0.55)
        fire.strokeColor = UIColor(red: 1.0, green: 0.78, blue: 0.28, alpha: 0.9)
        fire.lineWidth = 2
        fire.glowWidth = 1.2
        fire.zPosition = 1
        root.addChild(fire)

        let core = SKShapeNode(circleOfRadius: 8 * scale)
        core.fillColor = UIColor(red: 1.0, green: 0.95, blue: 0.75, alpha: 0.95)
        core.strokeColor = .clear
        core.zPosition = 2
        root.addChild(core)

        let ring = SKShapeNode(circleOfRadius: 22 * scale)
        ring.fillColor = .clear
        ring.strokeColor = UIColor(red: 1.0, green: 0.70, blue: 0.25, alpha: 0.85)
        ring.lineWidth = 2.4
        ring.zPosition = 3
        root.addChild(ring)

        for index in 0..<6 {
            let angle = CGFloat(index) * (.pi / 3.0) + CGFloat(Int(point.x + point.y) % 7) * 0.05
            let debris = SKShapeNode(circleOfRadius: 2.4 * scale)
            debris.fillColor = UIColor(red: 1.0, green: 0.55, blue: 0.18, alpha: 1.0)
            debris.strokeColor = .clear
            debris.position = CGPoint(x: cos(angle) * 6 * scale, y: sin(angle) * 4 * scale)
            debris.zPosition = 4
            root.addChild(debris)
            if !persistent {
                let outward = CGVector(dx: cos(angle) * 26 * scale, dy: sin(angle) * 18 * scale)
                debris.run(.sequence([
                    .group([
                        .move(by: outward, duration: 0.38),
                        .fadeOut(withDuration: 0.38)
                    ]),
                    .removeFromParent()
                ]))
            }
        }

        guard !persistent else { return }
        smoke.run(.sequence([
            .group([.scale(to: 1.55, duration: 0.42), .fadeOut(withDuration: 0.42)]),
            .removeFromParent()
        ]))
        fire.run(.sequence([
            .group([.scale(to: 1.7, duration: 0.28), .fadeOut(withDuration: 0.28)]),
            .removeFromParent()
        ]))
        core.run(.sequence([
            .group([.scale(to: 1.9, duration: 0.18), .fadeOut(withDuration: 0.18)]),
            .removeFromParent()
        ]))
        ring.run(.sequence([
            .group([.scale(to: 2.1, duration: 0.34), .fadeOut(withDuration: 0.34)]),
            .removeFromParent()
        ]))
        root.run(.sequence([.wait(forDuration: 0.45), .removeFromParent()]))
    }

    private func showRepairSpark(at point: CGPoint) {
        let spark = SKShapeNode(circleOfRadius: 5)
        spark.position = point + CGPoint(x: CGFloat.random(in: -18...18), y: CGFloat.random(in: 4...24))
        spark.fillColor = UIColor(red: 0.40, green: 1.0, blue: 0.95, alpha: 1.0)
        spark.strokeColor = .clear
        spark.zPosition = 275
        effectsLayer.addChild(spark)
        spark.run(.sequence([.fadeOut(withDuration: 0.25), .removeFromParent()]))
    }

    private func showSonarPing(at point: CGPoint, faction: Faction) {
        let color = faction == .enemy
            ? UIColor(red: 1.0, green: 0.34, blue: 0.25, alpha: 1.0)
            : UIColor(red: 0.32, green: 0.92, blue: 1.0, alpha: 1.0)
        let ring = SKShapeNode(ellipseOf: CGSize(width: 62, height: 28))
        ring.position = point
        ring.fillColor = color.withAlphaComponent(0.10)
        ring.strokeColor = color.withAlphaComponent(0.95)
        ring.lineWidth = 2
        ring.zPosition = 278
        effectsLayer.addChild(ring)
        ring.run(.sequence([.group([.scale(to: 2.1, duration: 0.45), .fadeOut(withDuration: 0.45)]), .removeFromParent()]))
    }

    private func showAntiSubmarineHit(at point: CGPoint, faction: Faction) {
        let color = faction == .enemy
            ? UIColor(red: 1.0, green: 0.42, blue: 0.28, alpha: 1.0)
            : UIColor(red: 0.28, green: 0.95, blue: 1.0, alpha: 1.0)

        let shockRing = SKShapeNode(ellipseOf: CGSize(width: 56, height: 22))
        shockRing.position = point
        shockRing.fillColor = color.withAlphaComponent(0.08)
        shockRing.strokeColor = color.withAlphaComponent(0.96)
        shockRing.lineWidth = 2.5
        shockRing.zPosition = 282
        effectsLayer.addChild(shockRing)
        shockRing.run(.sequence([
            .group([.scale(to: 1.85, duration: 0.42), .fadeOut(withDuration: 0.42)]),
            .removeFromParent()
        ]))

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "ASW HIT"
        label.fontSize = 10
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = point + CGPoint(x: 0, y: 34)
        label.zPosition = 283
        effectsLayer.addChild(label)
        label.run(.sequence([
            .group([.moveBy(x: 0, y: 12, duration: 0.48), .fadeOut(withDuration: 0.48)]),
            .removeFromParent()
        ]))
    }

    private func showNavalWaterImpact(
        at point: CGPoint,
        faction: Faction,
        scale: CGFloat,
        persistent: Bool = false
    ) {
        guard faction == .player || isVisible(point: point) else { return }

        let node = SKNode()
        node.position = point
        node.zPosition = 284

        let waterColor = UIColor(red: 0.62, green: 0.94, blue: 1.0, alpha: 1.0)
        let accentColor = faction == .enemy
            ? UIColor(red: 1.0, green: 0.70, blue: 0.42, alpha: 1.0)
            : UIColor(white: 1.0, alpha: 1.0)

        let wash = SKShapeNode(ellipseOf: CGSize(width: 58 * scale, height: 24 * scale))
        wash.fillColor = waterColor.withAlphaComponent(0.16)
        wash.strokeColor = waterColor.withAlphaComponent(0.92)
        wash.lineWidth = 3
        node.addChild(wash)

        let innerRing = SKShapeNode(ellipseOf: CGSize(width: 34 * scale, height: 13 * scale))
        innerRing.fillColor = UIColor.white.withAlphaComponent(0.10)
        innerRing.strokeColor = accentColor.withAlphaComponent(0.82)
        innerRing.lineWidth = 2
        node.addChild(innerRing)

        let columnPath = CGMutablePath()
        columnPath.move(to: CGPoint(x: -9 * scale, y: 1 * scale))
        columnPath.addQuadCurve(
            to: CGPoint(x: -4 * scale, y: 48 * scale),
            control: CGPoint(x: -13 * scale, y: 25 * scale)
        )
        columnPath.addQuadCurve(
            to: CGPoint(x: 6 * scale, y: 46 * scale),
            control: CGPoint(x: 1 * scale, y: 58 * scale)
        )
        columnPath.addQuadCurve(
            to: CGPoint(x: 10 * scale, y: 1 * scale),
            control: CGPoint(x: 14 * scale, y: 24 * scale)
        )
        columnPath.closeSubpath()
        let column = SKShapeNode(path: columnPath)
        column.fillColor = waterColor.withAlphaComponent(0.82)
        column.strokeColor = UIColor.white.withAlphaComponent(0.92)
        column.lineWidth = 1.8
        node.addChild(column)

        let crown = SKShapeNode(ellipseOf: CGSize(width: 22 * scale, height: 9 * scale))
        crown.position = CGPoint(x: 1 * scale, y: 47 * scale)
        crown.fillColor = UIColor.white.withAlphaComponent(0.88)
        crown.strokeColor = waterColor
        crown.lineWidth = 1.5
        node.addChild(crown)

        let dropletOffsets = [
            CGPoint(x: -24, y: 23), CGPoint(x: -16, y: 36),
            CGPoint(x: 18, y: 34), CGPoint(x: 27, y: 20)
        ]
        for (index, offset) in dropletOffsets.enumerated() {
            let radius: CGFloat = index.isMultiple(of: 2) ? 3.2 : 2.4
            let droplet = SKShapeNode(circleOfRadius: radius * scale)
            droplet.position = CGPoint(x: offset.x * scale, y: offset.y * scale)
            droplet.fillColor = index.isMultiple(of: 2) ? waterColor : UIColor.white
            droplet.strokeColor = .clear
            node.addChild(droplet)
        }

        effectsLayer.addChild(node)
        guard !persistent else { return }

        wash.run(.group([.scale(to: 1.8, duration: 0.48), .fadeOut(withDuration: 0.48)]))
        innerRing.run(.group([.scale(to: 2.15, duration: 0.44), .fadeOut(withDuration: 0.44)]))
        column.run(.group([.scaleY(to: 1.18, duration: 0.16), .fadeOut(withDuration: 0.52)]))
        crown.run(.group([.moveBy(x: 0, y: 8 * scale, duration: 0.42), .fadeOut(withDuration: 0.42)]))
        for child in node.children.dropFirst(4) {
            child.run(.group([
                .moveBy(x: child.position.x * 0.55, y: 10 * scale, duration: 0.44),
                .fadeOut(withDuration: 0.44)
            ]))
        }
        node.run(.sequence([.wait(forDuration: 0.56), .removeFromParent()]))
    }

    private func money(for faction: Faction) -> Int {
        faction == .enemy ? enemyMoney : playerMoney
    }

    private func changeMoney(for faction: Faction, by amount: Int) {
        switch faction {
        case .player:
            playerMoney = max(0, playerMoney + amount)
        case .enemy:
            enemyMoney = max(0, enemyMoney + amount)
        case .neutral:
            break
        }
    }

    private func setDestination(for entity: GameEntity, near point: CGPoint) {
        let destination = navigablePoint(for: entity.kind.domain, near: point)
        entity.destination = destination
        entity.path.removeAll()

        guard entity.kind.domain == .land || entity.kind.domain == .naval,
              let start = tile(at: entity.node.position),
              let goal = tile(at: destination),
              start != goal
        else { return }

        if let tilePath = pathTiles(from: start, to: goal, domain: entity.kind.domain), tilePath.count > 1 {
            entity.path = tilePath.dropFirst().map(tileCenter)
            entity.destination = entity.path.removeFirst()
        }
    }

    private func advancePath(for entity: GameEntity) {
        if entity.path.isEmpty {
            entity.destination = nil
        } else {
            entity.destination = entity.path.removeFirst()
        }
    }

    private func pathTiles(from start: TileCoord, to goal: TileCoord, domain: Domain) -> [TileCoord]? {
        guard isPassable(start, for: domain), isPassable(goal, for: domain) else { return nil }

        var open = Set([start])
        var cameFrom: [TileCoord: TileCoord] = [:]
        var gScore: [TileCoord: Int] = [start: 0]
        var fScore: [TileCoord: Int] = [start: heuristic(from: start, to: goal)]

        while let current = open.min(by: { (fScore[$0] ?? Int.max) < (fScore[$1] ?? Int.max) }) {
            if current == goal {
                return reconstructPath(cameFrom: cameFrom, current: current)
            }

            open.remove(current)
            for neighbor in neighbors(of: current, for: domain) {
                let tentativeScore = (gScore[current] ?? Int.max - 20) + movementCost(for: neighbor, domain: domain)
                if tentativeScore < (gScore[neighbor] ?? Int.max) {
                    cameFrom[neighbor] = current
                    gScore[neighbor] = tentativeScore
                    fScore[neighbor] = tentativeScore + heuristic(from: neighbor, to: goal)
                    open.insert(neighbor)
                }
            }
        }

        return nil
    }

    private func reconstructPath(cameFrom: [TileCoord: TileCoord], current: TileCoord) -> [TileCoord] {
        var current = current
        var path = [current]
        while let previous = cameFrom[current] {
            current = previous
            path.append(current)
        }
        return path.reversed()
    }

    private func neighbors(of tile: TileCoord, for domain: Domain) -> [TileCoord] {
        [
            TileCoord(row: tile.row - 1, col: tile.col),
            TileCoord(row: tile.row + 1, col: tile.col),
            TileCoord(row: tile.row, col: tile.col - 1),
            TileCoord(row: tile.row, col: tile.col + 1),
            TileCoord(row: tile.row - 1, col: tile.col + 1),
            TileCoord(row: tile.row + 1, col: tile.col - 1)
        ].filter { isPassable($0, for: domain) }
    }

    private func movementCost(for tile: TileCoord, domain: Domain) -> Int {
        switch domain {
        case .land:
            switch terrain(at: tile) {
            case .road:
                return 7
            case .oil:
                return 12
            default:
                return 10
            }
        case .naval:
            return 10
        case .air:
            return 8
        case .structure:
            return Int.max / 4
        }
    }

    private func isPassable(_ tile: TileCoord, for domain: Domain) -> Bool {
        switch domain {
        case .land:
            return isLand(tile)
        case .naval:
            return isValid(tile) && terrain(at: tile) == .water
        case .air:
            return isValid(tile)
        case .structure:
            return false
        }
    }

    private func heuristic(from start: TileCoord, to goal: TileCoord) -> Int {
        (abs(start.row - goal.row) + abs(start.col - goal.col)) * 7
    }

    private func navigablePoint(for domain: Domain, near point: CGPoint) -> CGPoint {
        switch domain {
        case .air:
            return point
        case .land:
            if let tile = tile(at: point), isLand(tile) {
                return tileCenter(tile)
            }
            return nearestPoint(matching: { self.isLand($0) }, near: point) ?? point
        case .naval:
            if let tile = tile(at: point), terrain(at: tile) == .water {
                return tileCenter(tile)
            }
            return nearestPoint(matching: { self.terrain(at: $0) == .water }, near: point) ?? point
        case .structure:
            return point
        }
    }

    private func isLand(_ tile: TileCoord) -> Bool {
        guard isValid(tile) else { return false }
        return terrain[tile.row][tile.col] != .water && terrain[tile.row][tile.col] != .ridge
    }

    private func terrain(at tile: TileCoord) -> Terrain {
        guard isValid(tile) else { return .ridge }
        return terrain[tile.row][tile.col]
    }

    private func isValid(_ tile: TileCoord) -> Bool {
        tile.row >= 0 && tile.row < rows && tile.col >= 0 && tile.col < cols
    }

    private func tileCenter(_ tile: TileCoord) -> CGPoint {
        CGPoint(
            x: CGFloat(tile.col - tile.row) * tileWidth / 2,
            y: -CGFloat(tile.col + tile.row) * tileHeight / 2
        )
    }

    private func tile(at point: CGPoint) -> TileCoord? {
        let a = point.x / (tileWidth / 2)
        let b = -point.y / (tileHeight / 2)
        let col = Int(round((a + b) / 2))
        let row = Int(round((b - a) / 2))
        let tile = TileCoord(row: row, col: col)
        return isValid(tile) ? tile : nil
    }

    private func clampCamera(_ position: CGPoint) -> CGPoint {
        let halfW = max(120, size.width * cameraRig.xScale / 2 - 100)
        let halfH = max(90, size.height * cameraRig.yScale / 2 - 80)
        if worldBounds.width <= halfW * 2 || worldBounds.height <= halfH * 2 {
            return CGPoint(x: worldBounds.midX, y: worldBounds.midY)
        }
        return CGPoint(
            x: min(max(position.x, worldBounds.minX + halfW), worldBounds.maxX - halfW),
            y: min(max(position.y, worldBounds.minY + halfH), worldBounds.maxY - halfH)
        )
    }

    private func entityZPosition(_ entity: GameEntity) -> CGFloat {
        var offset: CGFloat = 100
        if entity.kind.domain == .air { offset = 170 }
        if entity.kind.isStructure { offset = 90 }
        return zPosition(for: entity.node.position) + offset
    }

    private func zPosition(for point: CGPoint) -> CGFloat {
        -point.y * 0.1
    }

    private func diamondPath(width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -height / 2))
        path.addLine(to: CGPoint(x: -width / 2, y: 0))
        path.closeSubpath()
        return path
    }

    private func trianglePath(size: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size / 2))
        path.addLine(to: CGPoint(x: size / 2, y: -size / 2))
        path.addLine(to: CGPoint(x: -size / 2, y: -size / 2))
        path.closeSubpath()
        return path
    }

    private func derrickPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -18, y: -18))
        path.addLine(to: CGPoint(x: 0, y: 26))
        path.addLine(to: CGPoint(x: 18, y: -18))
        path.addLine(to: CGPoint(x: 10, y: -18))
        path.addLine(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: -10, y: -18))
        path.closeSubpath()
        return path
    }

    private func jetPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 28, y: 0))
        path.addLine(to: CGPoint(x: -18, y: 17))
        path.addLine(to: CGPoint(x: -8, y: 4))
        path.addLine(to: CGPoint(x: -30, y: 0))
        path.addLine(to: CGPoint(x: -8, y: -4))
        path.addLine(to: CGPoint(x: -18, y: -17))
        path.closeSubpath()
        return path
    }

    private func shipHullPath(width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width / 2 - 14, y: height / 2))
        path.addLine(to: CGPoint(x: -width / 2 + 10, y: height / 2))
        path.addLine(to: CGPoint(x: -width / 2, y: 0))
        path.addLine(to: CGPoint(x: -width / 2 + 10, y: -height / 2))
        path.addLine(to: CGPoint(x: width / 2 - 14, y: -height / 2))
        path.closeSubpath()
        return path
    }
}

private extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    var length: CGFloat {
        sqrt(x * x + y * y)
    }

    var normalized: CGPoint {
        let length = self.length
        if length <= 0.0001 {
            return .zero
        }
        return CGPoint(x: x / length, y: y / length)
    }

    func distance(to other: CGPoint) -> CGFloat {
        (self - other).length
    }
}

private extension UIColor {
    func darker(by amount: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(
            red: max(0, red - amount),
            green: max(0, green - amount),
            blue: max(0, blue - amount),
            alpha: alpha
        )
    }
}
