# Autonom: Tech-Stack Review

## Complete Pipeline & Architecture:
```
┌─────────────────────────────────────────────┐
│ 1. SENSOR LAYER                             │
│    Suricata + Wazuh                         │
├─────────────────────────────────────────────┤
│ 2. INGESTION & NORMALIZATION                │
│    Parsers + Common Event Schema            │
├─────────────────────────────────────────────┤
│ 3. CORRELATION & INCIDENT ENGINE            │
│    Alert correlation + incident creation    │
├─────────────────────────────────────────────┤
│ 4. INVESTIGATION ENGINE                     │
│    Evidence + Threat Intelligence           │
├─────────────────────────────────────────────┤
│ 5. AI REASONING LAYER                       │
│    Ollama + Local LLM                       │
├─────────────────────────────────────────────┤
│ 6. DECISION / POLICY ENGINE                 │
│    Risk + confidence + allowed actions      │
├─────────────────────────────────────────────┤
│ 7. RESPONSE & REMEDIATION ENGINE            │
│    Containment + remediation + verification │
├─────────────────────────────────────────────┤
│ 8. LEARNING / AUDIT LAYER                   │
│    Logs + new rules + threat intelligence   │
└─────────────────────────────────────────────┘
```

## Disection Of Layers:
### Sensor-Layer:
`Suricata` and `Wazuh` lies here! They both works as sensors and produce data, that is later processed.

**Suricata**:
```
NETWORK
   │
   ▼
SURICATA
   │
   ├── Network connections
   ├── Suspicious traffic
   ├── Exploit attempts
   ├── Port scans
   ├── Protocol anomalies
   └── IDS alerts
```
`Suricata` -> Produces `eve.json`
Sample-Output:
```
{
  "timestamp": "2026-08-11T15:30:00.123456+00:00",
  "flow_id": 1234567890123456,
  "event_type": "alert",
  "src_ip": "192.168.1.50",
  "src_port": 49152,
  "dest_ip": "203.0.113.5",
  "dest_port": 80,
  "proto": "TCP",
  "alert": {
    "action": "allowed",
    "gid": 1,
    "signature_id": 2014435,
    "rev": 15,
    "signature": "ET MALWARE Infostealer. Banprox Proxy. * Pac Download",
    "category": "A Network Trojan was detected",
    "severity": 1
  }
}
```

**Wazuh**:
In contrast to `Suricata`, which is bounded as on "monitoring-engine". `Wazuh`, is divided into `Server`-`Indexer`-`Dashboard`
```
ENDPOINT
   │
   ▼
WAZUH AGENT
   │
   ├── Authentication events
   ├── Processes
   ├── File changes
   ├── Logs
   ├── Vulnerabilities
   └── System activity
```

In order to make `Wazuh` & `Suricata` deployed and bundeled into single-bounded application.
`Docker-Container` => *The-Best-Approach*

### Ingestion & Normalization:
Since, `Suricata` & `Wazuh` does not produce structurlly identical data.
The files like (`eve.json`) and `Wazuh-Logs` needs to be parsed and put into a common schema.

*Proposed-Common-Schema*:
```
{
  "timestamp": "...",
  "source": "suricata",
  "event_type": "network_alert",
  "source_ip": "192.168.1.50",
  "destination_ip": "192.168.1.20",
  "destination_port": 22,
  "severity": 8,
  "evidence": {
    "signature": "SSH brute force"
  }
}
```

Script for Parsing:
```
import json

with open("eve.json", r) as file, open("alert.json", "w") as outfile:
    for line in file:
        try:
            log = json.load(line.strip())

            if log.get("event_type") == "alert":
                alertData = log.get("alert", {})

                event = {
                    "timestamp": log.get("timestamp"),
                    "source": "suricata",
                    "event_type": "network_alert",
                    "source_ip": log.get("src_ip"),
                    "destination_ip": log.get("dest_ip"),
                    "destination_port": log.get("dest_port"),
                    "severity": alertData.get("severity"),
                    "evidence": {
                        "signature": alertData.get("signature")
                    }
                }

                outfile.write(json.dump(event) + "\n")
        except json.JSONDecodeError:
            continue
```
