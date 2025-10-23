# 💧 CleanWater Network

A decentralized water quality monitoring and purification network built on blockchain technology. Connect communities, monitor water safety, fund purification projects, and ensure clean water access through transparent governance and collaborative management.

## 🌊 Features

- **👥 Network Membership**: Join with different roles (Manager, Technician, Researcher, Community)
- **🏭 Water Station Management**: Install, monitor, and maintain water purification stations
- **🧪 Quality Monitoring**: Submit detailed water quality reports with pH, TDS, and bacteria levels
- **💰 Project Funding**: Create and vote on purification projects with democratic governance
- **🔧 Maintenance Requests**: Report and track station maintenance needs
- **📊 Reputation System**: Build trust through active participation and project completion
- **💎 Treasury Management**: Transparent fund pooling for network sustainability
- **📈 Network Analytics**: Track water quality trends and project impact

## 🚰 How It Works

### Network Participation
1. **💳 Membership Registration**: Pay 25,000 µSTX to join with specified role
2. **📍 Location Mapping**: Provide location for regional water quality tracking
3. **⭐ Reputation Building**: Start with 100 reputation points
4. **🎯 Role-based Activities**: Engage based on your expertise and responsibilities

### Water Station Lifecycle
- **🏭 Installation**: Members install stations with capacity and cost tracking
- **🧪 Quality Testing**: Regular pH, TDS, and bacteria testing with safety ratings
- **📊 Data Verification**: Admin verification ensures data accuracy
- **🔧 Maintenance**: Request and track maintenance with urgency levels
- **💰 Funding**: Community funding for station upgrades and repairs

### Project Management
- **📋 Project Creation**: Propose purification projects with detailed specifications
- **💰 Funding Proposals**: Request community funding for projects
- **🗳️ Democratic Voting**: 720-block voting period for all funding decisions
- **⚡ Automatic Execution**: Approved projects receive immediate funding
- **📈 Progress Tracking**: Monitor project completion and impact

## 🔧 Contract Functions

### Network Membership

#### `join-network`
Join the CleanWater Network community.
```clarity
(join-network name location role)
```
- **name**: Member's name (max 256 chars)
- **location**: Geographic location (max 128 chars)
- **role**: Role type - "Manager", "Technician", "Researcher", "Community"
- **membership-fee**: 25,000 µSTX required
- **initial-reputation**: 100 points

### Water Station Operations

#### `install-water-station`
Install a new water purification station.
```clarity
(install-water-station name location capacity-liters installation-cost)
```
- **name**: Station identifier (max 256 chars)
- **location**: Station location (max 128 chars)
- **capacity-liters**: Daily water processing capacity
- **installation-cost**: Total installation cost in µSTX

#### `submit-quality-report`
Submit comprehensive water quality test results.
```clarity
(submit-quality-report station-id ph-level tds-ppm bacteria-count safety-rating)
```
- **station-id**: Target water station ID
- **ph-level**: pH measurement (scaled integer)
- **tds-ppm**: Total Dissolved Solids in parts per million
- **bacteria-count**: Bacterial contamination level
- **safety-rating**: Overall safety score (1-10 scale)

#### `request-maintenance`
Report station maintenance issues.
```clarity
(request-maintenance station-id issue-description urgency-level estimated-cost)
```
- **station-id**: Station requiring maintenance
- **issue-description**: Detailed issue description (max 512 chars)
- **urgency-level**: Priority level (1-5 scale)
- **estimated-cost**: Repair cost estimate

### Project Development

#### `create-purification-project`
Propose new water purification projects.
```clarity
(create-purification-project title description location project-type target-capacity estimated-cost deadline-blocks beneficiaries)
```
- **title**: Project title (max 256 chars)
- **description**: Detailed project description (max 512 chars)
- **location**: Project location (max 128 chars)
- **project-type**: Type of purification system (max 64 chars)
- **target-capacity**: Target daily water processing capacity
- **estimated-cost**: Total project cost in µSTX
- **deadline-blocks**: Project completion timeline
- **beneficiaries**: Number of people served

### Democratic Governance

#### `create-funding-proposal`
Submit funding requests for community vote.
```clarity
(create-funding-proposal project-id title description amount-requested)
```
- **project-id**: Associated purification project
- **title**: Funding proposal title (max 256 chars)
- **description**: Funding justification (max 512 chars)
- **amount-requested**: Minimum 100,000 µSTX
- **voting-duration**: 720 blocks (~5 days)

#### `vote-on-funding`
Vote on active funding proposals (members only).
```clarity
(vote-on-funding proposal-id vote-for)
```
- **proposal-id**: Proposal to vote on
- **vote-for**: true for yes, false for no
- **one-vote-limit**: One vote per member per proposal

#### `execute-funding-proposal`
Execute approved proposals after voting ends.
```clarity
(execute-funding-proposal proposal-id)
```
- Automatically transfers funds if approved (yes > no votes)
- Updates project status to "funded"

### Network Management

#### `contribute-to-treasury`
Make additional contributions to network treasury.
```clarity
(contribute-to-treasury amount)
```
- Increases member reputation score (amount/1000)
- Supports network sustainability

#### `complete-project`
Mark projects as completed (project manager only).
```clarity
(complete-project project-id)
```
- Awards 100 reputation points
- Updates project completion statistics

#### `verify-quality-report`
Verify submitted quality reports (admin only).
```clarity
(verify-quality-report report-id)
```

### Query Functions

#### `get-member`
Retrieve member profile and statistics.

#### `get-water-station`
Get detailed station information and current status.

#### `get-project`
View project details and funding status.

#### `get-proposal`
Access funding proposal details and voting results.

#### `get-quality-report`
View water quality test results and verification status.

#### `get-network-stats`
Get comprehensive network metrics and treasury status.

#### `get-station-quality`
Quickly check current water quality rating for a station.

## 🛠️ Usage Examples

### Join as Network Member
```bash
clarinet console
(contract-call? .cleanwater-network join-network 
  "Dr. Sarah Chen" 
  "Jakarta, Indonesia" 
  "Researcher")
```

### Install Water Station
```bash
(contract-call? .cleanwater-network install-water-station 
  "Jakarta Community Center Station" 
  "Central Jakarta District" 
  u5000 
  u150000)
```

### Submit Water Quality Report
```bash
(contract-call? .cleanwater-network submit-quality-report 
  u1 
  u720 
  u150 
  u5 
  u8)
```

### Create Purification Project
```bash
(contract-call? .cleanwater-network create-purification-project 
  "Advanced Filtration System Installation" 
  "Install multi-stage filtration system to serve 1000 families" 
  "East Jakarta" 
  "Multi-Stage Filtration" 
  u10000 
  u500000 
  u2160 
  u4000)
```

### Request Project Funding
```bash
(contract-call? .cleanwater-network create-funding-proposal 
  u1 
  "Phase 1 Equipment Purchase" 
  "Funding for filtration equipment and installation materials" 
  u200000)
```

### Vote on Funding
```bash
(contract-call? .cleanwater-network vote-on-funding u1 true)
```

### Execute Approved Proposal
```bash
(contract-call? .cleanwater-network execute-funding-proposal u1)
```

### Report Maintenance Issue
```bash
(contract-call? .cleanwater-network request-maintenance 
  u1 
  "Filtration membrane replacement needed - reduced water output" 
  u3 
  u25000)
```

### Check Network Statistics
```bash
(contract-call? .cleanwater-network get-network-stats)
```

## 🔧 Development Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet)
- Node.js (for testing)

### Installation
```bash
git clone <repository>
cd CleanWater-Network
clarinet check
```

### Testing
```bash
npm install
npm test
```

## 📖 Contract Details

- **Contract Name**: `cleanwater-network`
- **Network**: Stacks Blockchain
- **Language**: Clarity
- **Lines of Code**: 424
- **Membership Fee**: 25,000 µSTX
- **Min Funding**: 100,000 µSTX
- **Voting Period**: 720 blocks (~5 days)
- **Initial Reputation**: 100 points
- **Safety Rating Scale**: 1-10 (10 = safest)

## 🛡️ Security Features

- ✅ Member verification for all critical functions
- ✅ One-time registration per member
- ✅ Station ownership and management controls
- ✅ Quality report verification by admins
- ✅ Funding proposal amount validation (min 100,000 µSTX)
- ✅ Voting period enforcement
- ✅ One vote per member per proposal
- ✅ Project manager authorization for completion
- ✅ Treasury fund protection
- ✅ Maintenance request urgency validation (1-5 scale)

## 💰 Economics & Governance

### Network Treasury Sources
1. **Membership Fees**: 25,000 µSTX per new member
2. **Voluntary Contributions**: Additional member donations
3. **Reputation Incentives**: Contributions increase member reputation
4. **Network Growth**: Expanding membership and station network

### Democratic Decision Making
- **Open Proposals**: Any member can submit funding requests
- **Equal Voting**: One vote per active member
- **Majority Rule**: Proposals pass with yes > no votes
- **Transparent Process**: All votes recorded on blockchain
- **Automatic Execution**: Approved proposals trigger immediate funding

### Reputation System
- **Base Score**: 100 points for new members
- **Contribution Bonus**: Points for treasury contributions (amount/1000)
- **Completion Rewards**: 100 points for completing projects
- **Station Management**: Track stations managed per member
- **Activity Tracking**: Project completions and network participation

## 🌍 Water Quality Use Cases

### Community Water Stations
- **🏘️ Residential Areas**: Install stations in neighborhoods and apartment complexes
- **🏫 Schools & Hospitals**: Ensure safe water access in critical facilities
- **🏭 Industrial Zones**: Monitor water quality near manufacturing areas
- **🌾 Rural Communities**: Provide clean water access to remote villages

### Water Quality Monitoring
- **🧪 Comprehensive Testing**: pH levels, dissolved solids, bacterial contamination
- **📊 Trend Analysis**: Track water quality improvements over time
- **⚠️ Early Warning**: Detect contamination before it becomes critical
- **🏆 Quality Assurance**: Verify purification system effectiveness

### Purification Technologies
- **🔬 Advanced Filtration**: Multi-stage filtration systems
- **💡 UV Sterilization**: Ultraviolet water disinfection
- **⚗️ Reverse Osmosis**: High-efficiency contaminant removal
- **🌿 Bio-remediation**: Natural water treatment solutions

## 📊 Platform Analytics

Track key network performance metrics:
- Total network members by role and geographic distribution
- Active water stations and daily processing capacity
- Water quality trends and safety improvement rates
- Funding proposals success rates and amounts distributed
- Member reputation scores and participation levels
- Project completion rates and community impact
- Maintenance request response times and resolution rates

## 🌟 Impact & Outcomes

### Public Health Benefits
- **Safe Water Access**: Ensure consistent access to clean, safe drinking water
- **Disease Prevention**: Reduce waterborne illness through quality monitoring
- **Community Health**: Improve overall community health outcomes
- **Emergency Response**: Rapid response to water contamination events

### Economic Benefits
- **Cost Efficiency**: Shared infrastructure reduces individual costs
- **Local Economy**: Projects create jobs and stimulate economic activity
- **Sustainable Development**: Long-term water security planning
- **Resource Optimization**: Efficient allocation of purification resources

### Social Impact
- **Community Engagement**: Shared governance builds stronger communities
- **Technical Skills**: Members develop water management expertise
- **Democratic Participation**: Direct democracy in resource allocation
- **Knowledge Sharing**: Best practices spread across network

## 🚀 Future Enhancements

- **🌐 Global Network**: Connect water networks worldwide
- **📱 Mobile App**: Real-time water quality monitoring on smartphones
- **🤖 IoT Integration**: Automated sensor data collection and reporting
- **📊 AI Analytics**: Machine learning for predictive maintenance
- **🔗 Government API**: Integration with municipal water systems
- **💡 Smart Contracts**: Automated maintenance scheduling and alerts
- **🌍 Climate Integration**: Track climate change impact on water quality

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `clarinet check`
5. Submit a pull request

## 📄 License

This project is open source. See LICENSE file for details.

## 🆘 Support

For questions or technical assistance:
- Create an issue on GitHub
- Join our community Discord
- Contact the network administrators
- Emergency water quality hotline

---

*Ensuring clean water access through decentralized cooperation* 💧🤝
