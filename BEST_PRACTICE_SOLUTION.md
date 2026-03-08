# Best Practice Solution - SFTP Servers Setup

## ✅ Problem & Solution

### Problem
- SFTP source sudah ada di `C:\Users\dihar\workspace\SFTP` (Docker Compose)
- SFTP target belum ada
- Aplikasi running menggunakan `./startSync.sh`
- Butuh setup untuk testing copy antar 2 SFTP servers

### Solution ✨
**Single Docker Compose dengan 2 SFTP Services** - Best Practice untuk development/testing

## 🎯 Why This is Best Practice

| Aspect | Approach | Benefit |
|--------|----------|---------|
| **Simplicity** | Single docker-compose.yml | Easy management, satu command start/stop |
| **Isolation** | 2 containers dengan port berbeda | No conflicts, independent testing |
| **Data Persistence** | Local mounted volumes | Data tidak hilang saat container restart |
| **Automation** | Helper script `manage-sftp.sh` | Simplify operations |
| **Integration** | Auto-check di `startSync.sh` | Prevent errors, better UX |
| **Scalability** | Easy to add more servers | Copy-paste service config |

## 📁 What Has Been Created

### 1. Updated Docker Compose
**File**: `C:\Users\dihar\workspace\SFTP\docker-compose.yml`

```yaml
services:
  sftp-source:    # Port 2222 (sudah ada)
    ports: ["2222:22"]

  sftp-target:    # Port 2223 (baru ditambahkan)
    ports: ["2223:22"]
```

### 2. Management Script
**File**: `C:\Users\dihar\workspace\SFTP\manage-sftp.sh`

Commands:
- `./manage-sftp.sh start` - Start both servers
- `./manage-sftp.sh stop` - Stop both servers
- `./manage-sftp.sh status` - Check status
- `./manage-sftp.sh logs` - View logs
- `./manage-sftp.sh info` - Connection details

### 3. Updated Application Config
**File**: `C:\Users\dihar\workspace\jalin\dev\engine\application.yaml`

```yaml
sync:
  sftp:
    source:
      port: 2222    # Source SFTP
    target:
      port: 2223    # Target SFTP (beda port!)
```

### 4. Enhanced Start Script
**File**: `C:\Users\dihar\workspace\jalin\dev\engine\startSync.sh`

- Auto-check if SFTP servers running
- Warning jika servers belum start
- Option to continue or abort

### 5. Documentation
- `SFTP_SETUP_GUIDE.md` - Complete technical guide
- `README.md` - Updated with 2-server setup
- `BEST_PRACTICE_SOLUTION.md` - This file

### 6. Directory Structure
```
C:\Users\dihar\workspace\SFTP\
├── docker-compose.yml          # Updated: 2 SFTP services
├── manage-sftp.sh              # New: Management script
├── source_data/                # Existing: Source data
│   ├── claim_evidence/
│   └── archive/
├── target_data/                # New: Target data
│   ├── claim_evidence/
│   └── archive/
├── SFTP_SETUP_GUIDE.md         # New: Complete guide
└── README.md                   # Updated: 2-server setup
```

## 🚀 Quick Start Guide

### Step 1: Start SFTP Servers

```bash
cd C:\Users\dihar\workspace\SFTP
./manage-sftp.sh start
```

Expected output:
```
Starting SFTP servers...
✓ Target directories created
✓ SFTP servers started successfully

Server Status:
  Source Server: Running (localhost:2222)
  Target Server: Running (localhost:2223)
```

### Step 2: Verify Status

```bash
./manage-sftp.sh status
```

### Step 3: Run Sync Engine

```bash
cd C:\Users\dihar\workspace\jalin\dev\engine
./startSync.sh
```

The script will now:
1. ✅ Check if SFTP servers running
2. ✅ Warn if servers not running
3. ✅ Ask to continue or abort
4. ✅ Start application with proper checks

## 🔧 Configuration Summary

### Development (Local Docker)
```yaml
source:
  host: localhost
  port: 2222

target:
  host: localhost
  port: 2223
```

### Production (Actual Servers)
```yaml
source:
  host: 1.1.1.1          # Actual IP
  port: 22

target:
  host: 2.2.2.2          # Actual IP
  port: 22
```

## 📊 Comparison: Before vs After

### Before (Problem)
```
❌ Only 1 SFTP server (source)
❌ Target server belum ada
❌ Manual setup untuk target
❌ No management script
❌ No validation in start script
```

### After (Solution)
```
✅ 2 SFTP servers in one compose
✅ Ready-to-use setup
✅ Automated management script
✅ Validation in start script
✅ Complete documentation
```

## 🎓 Key Principles

### 1. Single Source of Truth
- One docker-compose.yml manages both servers
- Easy to version control
- Easy to share with team

### 2. Automation Over Manual
- Helper script for common tasks
- Auto-check in start script
- Prevent human errors

### 3. Documentation-First
- Complete setup guide
- Clear examples
- Troubleshooting section

### 4. Production-Mirroring
- Local setup mirrors production
- Same workflow, different hosts
- Easy to switch between envs

### 5. Fail-Safe Design
- Pre-flight checks
- Clear error messages
- Graceful degradation

## 🧪 Testing Workflow

### Complete Test Scenario

```bash
# 1. Start SFTP servers
cd C:\Users\dihar\workspace\SFTP
./manage-sftp.sh start

# 2. Add test files to source
cp /path/to/test1.jpg source_data/claim_evidence/
cp /path/to/test2.png source_data/claim_evidence/

# 3. Run sync engine
cd ../jalin/dev/engine
./startSync.sh

# 4. Verify results
# Source files should be archived
ls ../SFTP/source_data/archive/$(date +%Y-%m-%d)/

# Target files should be copied
ls ../SFTP/target_data/claim_evidence/$(date +%Y-%m-%d)/
```

## 📝 Scripts Reference

### manage-sftp.sh

| Command | Description |
|---------|-------------|
| `start` | Start both SFTP servers |
| `stop` | Stop both SFTP servers |
| `restart` | Restart both servers |
| `status` | Show running status |
| `logs` | Show container logs |
| `info` | Show connection details |

### startSync.sh (Enhanced)

New features:
- ✅ Pre-flight check for SFTP servers
- ✅ Warning if servers not running
- ✅ Interactive prompt to continue/abort
- ✅ Clear status messages

## 🔒 Security Notes

### Development Environment
- ✅ Default credentials OK
- ✅ Localhost only OK
- ✅ Non-standard ports OK

### Production Environment
- ❌ Change default passwords
- ❌ Use SSH keys
- ❌ Restrict IP access
- ❌ Enable firewall
- ❌ Use VPN if needed

## 🎯 Benefits Summary

1. **Ease of Use**: Single command to start both servers
2. **Consistency**: Same setup across team members
3. **Reliability**: Auto-checks prevent errors
4. **Maintainability**: Clear structure and documentation
5. **Scalability**: Easy to add more servers
6. **Testability**: Complete isolated test environment

## 📚 Related Documentation

- `SFTP_SETUP_GUIDE.md` - Complete technical documentation
- `README.md` - Quick reference
- `../jalin/dev/engine/SFTP_COPY_FEATURE.md` - Feature docs
- `../jalin/dev/engine/SFTP_COPY_QUICK_START.md` - Quick start

## ✅ Next Steps

1. ✅ Setup complete - ready to use
2. ✅ Test with sample files
3. ✅ Verify copy and archive workflow
4. ✅ Check logs for any issues
5. ✅ Deploy to production when ready

## 🎉 Conclusion

This setup provides:
- **Complete** testing environment
- **Simple** management workflow
- **Reliable** operation with checks
- **Documented** process and procedures
- **Production-ready** configuration

Best practice achieved! ✨
