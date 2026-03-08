# SFTP Servers Setup - Best Practice Guide

## 📋 Overview

Setup ini menggunakan **single Docker Compose** dengan dua SFTP services untuk testing dan development:
- **SFTP Source**: Port 2222 (simulasi IP 1.1.1.1)
- **SFTP Target**: Port 2223 (simulasi IP 2.2.2.2)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Network                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐         ┌──────────────────┐         │
│  │  SFTP Source     │         │  SFTP Target     │         │
│  │  Port: 2222      │         │  Port: 2223      │         │
│  │  Container:      │         │  Container:      │         │
│  │  sftp_source_    │         │  sftp_target_    │         │
│  │  server          │         │  server          │         │
│  ├──────────────────┤         ├──────────────────┤         │
│  │ /claim_evidence  │         │ /claim_evidence  │         │
│  │ /archive         │         │ /archive         │         │
│  └──────────────────┘         └──────────────────┘         │
│         ↓                            ↑                       │
│         │ Copy & Archive             │                       │
└─────────┼────────────────────────────┼──────────────────────┘
          │                            │
          └────────────┬───────────────┘
                       │
                ┌──────▼──────┐
                │ Sync Engine │
                │ (Spring     │
                │  Boot App)  │
                └─────────────┘
```

## 🚀 Quick Start

### 1. Start SFTP Servers

```bash
cd C:\Users\dihar\workspace\SFTP
./manage-sftp.sh start
```

### 2. Verify Status

```bash
./manage-sftp.sh status
```

Expected output:
```
SFTP Servers Status:
====================
  Source Server: Running (localhost:2222)
  Target Server: Running (localhost:2223)

Container Details:
NAMES                 STATUS          PORTS
sftp_source_server    Up 2 minutes    0.0.0.0:2222->22/tcp
sftp_target_server    Up 2 minutes    0.0.0.0:2223->22/tcp
```

### 3. Start Sync Engine

```bash
cd C:\Users\dihar\workspace\jalin\dev\engine
./startSync.sh
```

## 📁 Directory Structure

```
C:\Users\dihar\workspace\SFTP\
├── docker-compose.yml          # Docker Compose config (2 SFTP services)
├── manage-sftp.sh              # SFTP servers management script
├── source_data/                # Source SFTP data (mounted volume)
│   ├── claim_evidence/         # Source files location
│   └── archive/                # Archived files location
├── target_data/                # Target SFTP data (mounted volume)
│   ├── claim_evidence/         # Target files location
│   └── archive/                # Archive location (optional)
└── README.md                   # Original documentation
```

## 🔧 Configuration

### Docker Compose (docker-compose.yml)

```yaml
services:
  sftp-source:
    image: atmoz/sftp
    container_name: sftp_source_server
    ports:
      - "2222:22"               # Port 2222 untuk source
    volumes:
      - ./source_data/claim_evidence:/home/tester/claim_evidence
      - ./source_data/archive:/home/tester/archive
    command: tester:password123:::claim_evidence,archive

  sftp-target:
    image: atmoz/sftp
    container_name: sftp_target_server
    ports:
      - "2223:22"               # Port 2223 untuk target
    volumes:
      - ./target_data/claim_evidence:/home/tester/claim_evidence
      - ./target_data/archive:/home/tester/archive
    command: tester:password123:::claim_evidence,archive
```

### Application Configuration (application.yaml)

```yaml
sync:
  sftp-copy:
    enabled: true

  sftp:
    source:
      host: localhost
      port: 2222                # Source SFTP port
      username: tester
      password: password123
      path: /claim_evidence

    target:
      host: localhost
      port: 2223                # Target SFTP port (beda!)
      username: tester
      password: password123
      path: /claim_evidence
```

## 🛠️ Management Commands

### manage-sftp.sh Commands

```bash
# Start servers
./manage-sftp.sh start

# Stop servers
./manage-sftp.sh stop

# Restart servers
./manage-sftp.sh restart

# Check status
./manage-sftp.sh status

# View logs
./manage-sftp.sh logs

# Show connection info
./manage-sftp.sh info
```

### Manual Docker Commands

```bash
# Start specific server
docker start sftp_source_server
docker start sftp_target_server

# Stop specific server
docker stop sftp_source_server
docker stop sftp_target_server

# View logs
docker logs -f sftp_source_server
docker logs -f sftp_target_server

# Access container shell
docker exec -it sftp_source_server bash
docker exec -it sftp_target_server bash
```

## 🧪 Testing Connection

### Using SFTP Client

```bash
# Test source server
sftp -P 2222 tester@localhost

# Test target server
sftp -P 2223 tester@localhost
```

### Using curl

```bash
# Test source server
curl -v sftp://tester:password123@localhost:2222/

# Test target server
curl -v sftp://tester:password123@localhost:2223/
```

### From Java Application

The SftpCopyService will automatically test connections when you run the application.

## 📝 Workflow Test

### 1. Prepare Test Files

```bash
# Copy test images to source folder
cp /path/to/test1.jpg C:\Users\dihar\workspace\SFTP\source_data\claim_evidence\
cp /path/to/test2.png C:\Users\dihar\workspace\SFTP\source_data\claim_evidence\
```

### 2. Run Sync Engine

```bash
cd C:\Users\dihar\workspace\jalin\dev\engine
./startSync.sh
```

### 3. Verify Results

**Check Source Server:**
```bash
# Files should be moved to archive
ls C:\Users\dihar\workspace\SFTP\source_data\claim_evidence\
# Expected: empty

ls C:\Users\dihar\workspace\SFTP\source_data\archive\2026-03-08\
# Expected: test1.jpg, test2.png
```

**Check Target Server:**
```bash
# Files should be copied with date folder
ls C:\Users\dihar\workspace\SFTP\target_data\claim_evidence\2026-03-08\
# Expected: test1.jpg, test2.png
```

## 🔒 Security Best Practices

### For Development/Testing:
- ✅ Default credentials (tester:password123) OK
- ✅ Ports 2222-2223 OK (non-standard)
- ✅ Localhost only OK

### For Production:
- ❌ Change default passwords
- ❌ Use SSH keys instead of passwords
- ❌ Restrict IP access
- ❌ Use firewall rules
- ❌ Enable encryption
- ❌ Use proper user permissions

## 🐛 Troubleshooting

### Issue: Port Already in Use

```bash
# Check what's using the port
netstat -ano | findstr :2222
netstat -ano | findstr :2223

# Kill the process or change ports in docker-compose.yml
```

### Issue: Container Won't Start

```bash
# Check logs
docker logs sftp_source_server
docker logs sftp_target_server

# Remove and recreate
docker-compose down
docker-compose up -d
```

### Issue: Permission Denied

```bash
# Fix directory permissions on Windows
# Run Git Bash or Terminal as Administrator

# Or check ownership inside container
docker exec -it sftp_source_server ls -la /home/tester/
```

### Issue: Files Not Copied

1. Check SFTP servers are running: `./manage-sftp.sh status`
2. Check application logs: `tail -f logs/sync_engine_*.log`
3. Verify configuration in `application.yaml`
4. Test SFTP connection manually using `sftp` command

## 📊 Monitoring

### Check Docker Resource Usage

```bash
docker stats sftp_source_server sftp_target_server
```

### Check Disk Space

```bash
# Check source data size
du -sh C:\Users\dihar\workspace\SFTP\source_data\*

# Check target data size
du -sh C:\Users\dihar\workspace\SFTP\target_data\*
```

## 🚀 Production Deployment

When deploying to production:

1. **Use Separate SFTP Servers**
   - Don't use Docker Compose
   - Use actual SFTP servers at IP 1.1.1.1 and 2.2.2.2

2. **Update Configuration**
   ```yaml
   sync:
     sftp:
       source:
         host: 1.1.1.1          # Actual source IP
         port: 22
       target:
         host: 2.2.2.2          # Actual target IP
         port: 22
   ```

3. **Security Hardening**
   - Change credentials
   - Use SSH keys
   - Enable firewall
   - Setup VPN if needed

## 📚 Additional Resources

- [SFTP Docker Image Documentation](https://hub.docker.com/r/atmoz/sftp)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [JSch Library Documentation](http://www.jcraft.com/jsch/)

## ✅ Best Practice Summary

| Aspect | Best Practice | Why |
|--------|--------------|-----|
| **Server Management** | Single docker-compose.yml | Easier management |
| **Port Allocation** | Different ports (2222, 2223) | Avoid conflicts |
| **Data Storage** | Local mounted volumes | Data persistence |
| **Scripting** | manage-sftp.sh helper | Simplify operations |
| **Testing** | Use localhost first | Safe testing |
| **Production** | Use actual SFTP servers | Realistic environment |

This setup provides a complete, isolated testing environment that mirrors production while keeping everything simple and manageable.
