# Experiment 1: Design and Simulation of Bus and Star Topology in Cisco Packet Tracer

---

# Part A: Star Topology

## Aim

To design and simulate a Star Topology using Cisco Packet Tracer.

---

## Devices Required

From **End Devices**:

* 4 × PC-PT

From **Network Devices → Switches**:

* 1 × Switch-PT (2960)

---

## Step 1: Place the Devices

Drag and drop:

| Device      | Name    |
| ----------- | ------- |
| PC-PT       | PC0     |
| PC-PT       | PC1     |
| PC-PT       | PC2     |
| PC-PT       | PC3     |
| Switch 2960 | Switch0 |

Place Switch0 in the center.

Arrange PCs around the switch.

---

## Step 2: Connect Devices

Select:

**Connections → Copper Straight-Through Cable**

Make the following connections:

| From Device | Port          | To Device | Port            |
| ----------- | ------------- | --------- | --------------- |
| PC0         | FastEthernet0 | Switch0   | FastEthernet0/1 |
| PC1         | FastEthernet0 | Switch0   | FastEthernet0/2 |
| PC2         | FastEthernet0 | Switch0   | FastEthernet0/3 |
| PC3         | FastEthernet0 | Switch0   | FastEthernet0/4 |

Wait until all links become green.

---

## Step 3: Configure IP Addresses

### PC0

Desktop → IP Configuration

```text
IP Address: 192.168.1.1
Subnet Mask: 255.255.255.0
```

### PC1

```text
IP Address: 192.168.1.2
Subnet Mask: 255.255.255.0
```

### PC2

```text
IP Address: 192.168.1.3
Subnet Mask: 255.255.255.0
```

### PC3

```text
IP Address: 192.168.1.4
Subnet Mask: 255.255.255.0
```

Gateway is not required.

---

## Step 4: Verify Connectivity

On PC0:

Desktop → Command Prompt

```bash
ping 192.168.1.2
ping 192.168.1.3
ping 192.168.1.4
```

Expected:

```text
Reply from ...
```

No packet loss.

---

## Result

Star Topology successfully simulated.

---

# Part B: Bus Topology

> Cisco Packet Tracer does not contain a dedicated Bus Topology cable like old Ethernet coaxial networks. Therefore, a logical Bus Topology is simulated using a Hub.

---

## Devices Required

From End Devices:

* 4 × PC-PT

From Network Devices → Hubs

* 1 × Hub-PT

---

## Step 1: Place Devices

| Device | Name |
| ------ | ---- |
| PC0    | PC0  |
| PC1    | PC1  |
| PC2    | PC2  |
| PC3    | PC3  |
| Hub    | Hub0 |

Place Hub0 in center.

---

## Step 2: Cabling

Use:

**Copper Straight-Through Cable**

| From | Port          | To   | Port  |
| ---- | ------------- | ---- | ----- |
| PC0  | FastEthernet0 | Hub0 | Port1 |
| PC1  | FastEthernet0 | Hub0 | Port2 |
| PC2  | FastEthernet0 | Hub0 | Port3 |
| PC3  | FastEthernet0 | Hub0 | Port4 |

---

## Step 3: IP Configuration

### PC0

```text
192.168.10.1
255.255.255.0
```

### PC1

```text
192.168.10.2
255.255.255.0
```

### PC2

```text
192.168.10.3
255.255.255.0
```

### PC3

```text
192.168.10.4
255.255.255.0
```

---

## Step 4: Test

From PC0:

```bash
ping 192.168.10.2
ping 192.168.10.3
ping 192.168.10.4
```

Replies should be successful.

---

## Result

Bus Topology successfully simulated using a Hub.

---

# Experiment 2: Design and Simulation of Mesh and Ring Topology in Cisco Packet Tracer

---

# Part A: Mesh Topology

## Aim

To create a Full Mesh Topology.

---

## Devices Required

* 4 × Switch-PT (2960)

Names:

```text
Switch0
Switch1
Switch2
Switch3
```

---

## Step 1: Place Switches

Arrange them in a square.

```text
Switch0 ----- Switch1
   |             |
   |             |
Switch2 ----- Switch3
```

---

## Step 2: Connect Every Switch to Every Other Switch

Use:

**Copper Cross-Over Cable**

### Connections

| From    | Port  | To      | Port  |
| ------- | ----- | ------- | ----- |
| Switch0 | Fa0/1 | Switch1 | Fa0/1 |
| Switch0 | Fa0/2 | Switch2 | Fa0/1 |
| Switch0 | Fa0/3 | Switch3 | Fa0/1 |
| Switch1 | Fa0/2 | Switch2 | Fa0/2 |
| Switch1 | Fa0/3 | Switch3 | Fa0/2 |
| Switch2 | Fa0/3 | Switch3 | Fa0/3 |

This creates a Full Mesh.

---

## Step 3: Add PCs

Add:

* PC0
* PC1
* PC2
* PC3

---

## Step 4: Connect PCs

Use:

**Copper Straight-Through**

| PC  | Port | Switch  | Port   |
| --- | ---- | ------- | ------ |
| PC0 | Fa0  | Switch0 | Fa0/10 |
| PC1 | Fa0  | Switch1 | Fa0/10 |
| PC2 | Fa0  | Switch2 | Fa0/10 |
| PC3 | Fa0  | Switch3 | Fa0/10 |

---

## Step 5: Configure IP

| Device | IP       |
| ------ | -------- |
| PC0    | 10.0.0.1 |
| PC1    | 10.0.0.2 |
| PC2    | 10.0.0.3 |
| PC3    | 10.0.0.4 |

Subnet Mask:

```text
255.255.255.0
```

---

## Step 6: Verify

From PC0:

```bash
ping 10.0.0.2
ping 10.0.0.3
ping 10.0.0.4
```

Successful replies expected.

---

## Result

Full Mesh Topology successfully created.

---

# Part B: Ring Topology

---

## Devices Required

* 4 × Switch-PT 2960
* 4 × PC-PT

---

## Step 1: Place Devices

Arrange switches in a circle.

```text
Switch0 → Switch1
 ↑          ↓
Switch3 ← Switch2
```

---

## Step 2: Connect Switches

Use:

**Copper Cross-Over Cable**

| From    | Port  | To      | Port  |
| ------- | ----- | ------- | ----- |
| Switch0 | Fa0/1 | Switch1 | Fa0/1 |
| Switch1 | Fa0/2 | Switch2 | Fa0/1 |
| Switch2 | Fa0/2 | Switch3 | Fa0/1 |
| Switch3 | Fa0/2 | Switch0 | Fa0/2 |

---

## Step 3: Connect PCs

Use:

**Copper Straight-Through Cable**

| PC  | Port | Switch  | Port   |
| --- | ---- | ------- | ------ |
| PC0 | Fa0  | Switch0 | Fa0/10 |
| PC1 | Fa0  | Switch1 | Fa0/10 |
| PC2 | Fa0  | Switch2 | Fa0/10 |
| PC3 | Fa0  | Switch3 | Fa0/10 |

---

## Step 4: Configure IP

| PC  | IP Address |
| --- | ---------- |
| PC0 | 172.16.1.1 |
| PC1 | 172.16.1.2 |
| PC2 | 172.16.1.3 |
| PC3 | 172.16.1.4 |

Subnet:

```text
255.255.255.0
```

---

## Step 5: Verify

From PC0:

```bash
ping 172.16.1.4
```

Ping should succeed.

---

## Result

Ring Topology successfully simulated.

---

# Experiment 3: Configuring DHCP on a Server in Cisco Packet Tracer

---

## Aim

To configure a DHCP Server and automatically assign IP addresses to clients.

---

## Devices Required

| Device      | Quantity |
| ----------- | -------- |
| Server-PT   | 1        |
| Switch 2960 | 1        |
| PC-PT       | 4        |

---

## Step 1: Place Devices

```text
Server0
   |
Switch0
 / | | \
PC0 PC1 PC2 PC3
```

---

## Step 2: Connect Devices

Use:

**Copper Straight-Through Cable**

| From    | Port          | To      | Port            |
| ------- | ------------- | ------- | --------------- |
| Server0 | FastEthernet0 | Switch0 | FastEthernet0/1 |
| PC0     | FastEthernet0 | Switch0 | FastEthernet0/2 |
| PC1     | FastEthernet0 | Switch0 | FastEthernet0/3 |
| PC2     | FastEthernet0 | Switch0 | FastEthernet0/4 |
| PC3     | FastEthernet0 | Switch0 | FastEthernet0/5 |

---

## Step 3: Configure Server IP

Click:

Server0 → Desktop → IP Configuration

Set:

```text
IP Address : 192.168.100.1
Subnet Mask : 255.255.255.0
Default Gateway : 192.168.100.1
```

---

## Step 4: Configure DHCP Service

Server0 → Services → DHCP

Turn:

```text
DHCP Service = ON
```

Fill:

```text
Pool Name: LABPOOL

Default Gateway:
192.168.100.1

DNS Server:
8.8.8.8

Start IP Address:
192.168.100.10

Subnet Mask:
255.255.255.0

Maximum Number of Users:
100
```

Click:

```text
Add
```

---

## Step 5: Configure PCs

For each PC:

Desktop → IP Configuration

Select:

```text
DHCP
```

The server should automatically assign:

```text
192.168.100.10
192.168.100.11
192.168.100.12
...
```

---

## Step 6: Verify

On PC0:

Command Prompt

```bash
ipconfig
```

You should see a DHCP-assigned IP.

Now:

```bash
ping 192.168.100.1
```

Reply should be received.

---

## Step 7: Verify Between Clients

From PC0:

```bash
ping 192.168.100.11
ping 192.168.100.12
```

Successful replies confirm DHCP and connectivity are working.

---

## Result

DHCP Server successfully configured and IP addresses assigned dynamically to all clients.
