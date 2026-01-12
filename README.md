# 🌍 Astra Linux Threat Geo Mapper

A sophisticated web-based visualization tool for mapping and analyzing Astra Linux systems detected through network reconnaissance. This tool helps security researchers and system administrators visualize the geographical distribution of Astra Linux deployments with threat assessment capabilities.

![Astra Linux Threat Geo Mapper](https://img.shields.io/badge/Status-Active-brightgreen) ![License](https://img.shields.io/badge/License-MIT-blue) ![HTML5](https://img.shields.io/badge/HTML5-E34F26?logo=html5&logoColor=white) ![CSS3](https://img.shields.io/badge/CSS3-1572B6?logo=css3&logoColor=white) ![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?logo=javascript&logoColor=black)


<h1 align="center">
<br>
<img src=screenshots/astra-mapper.png >
<br>
</h1>


## 🎯 Features

### Core Functionality
- **Interactive Mapping**: Real-time visualization of Astra Linux systems on a dark-themed world map
- **Threat Assessment**: Automated risk scoring based on port usage, SSH configuration, and geographical factors
- **Data Analytics**: Comprehensive statistics including host counts, country distribution, and risk metrics
- **Responsive Design**: Optimized for desktop and mobile viewing

### Threat Level Classification
- **🔴 Critical**: Multiple exposed services or suspicious configurations
- **🟠 High**: Non-standard SSH ports or elevated risk factors
- **🟢 Medium**: Standard SSH on port 22 with normal configurations  
- **🔵 Low**: HTTPS/Web services with minimal risk indicators

### Visual Elements
- **Gradient Markers**: Color-coded threat indicators with size scaling
- **Detailed Popups**: Comprehensive system information on click
- **Real-time Stats**: Live updating statistics dashboard
- **Modern UI**: Glassmorphism design with backdrop blur effects

## 🚀 Quick Start

### Prerequisites
- Modern web browser with JavaScript enabled
- Web server (optional, but recommended for local development)
- Docker (optional, for containerized deployment)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/BuildAndDestroy/astra-geo-mapper.git
   cd astra-geo-mapper
   ```

2. **Launch the application:**
   
   **Option A: Docker (Recommended for Production)**
   ```bash
   # Using docker-compose
   docker-compose up -d
   
   # Or using Docker directly
   docker build -t astra-geo-mapper .
   docker run -d -p 8080:80 astra-geo-mapper
   
   # Or using Makefile
   make build && make run
   
   # Then navigate to http://localhost:8080
   ```
   
   **Option B: Direct file opening**
   ```bash
   # Open secure version directly in browser
   open astra_geo_mapper_secure.html
   # or
   firefox astra_geo_mapper_secure.html
   ```
   
   **Option C: Local web server (recommended for development)**
   ```bash
   # Using Python 3
   python -m http.server 8000
   
   # Using Node.js
   npx http-server
   
   # Then navigate to http://localhost:8000/astra_geo_mapper_secure.html
   ```

### Pre-commit Hooks Setup

Install pre-commit hooks for secret detection and code quality:

```bash
# Install dependencies
pip install pre-commit detect-secrets

# Install hooks
pre-commit install

# Generate secrets baseline (first time)
make secrets-baseline

# Run checks manually
make test
```

See [README_DOCKER.md](README_DOCKER.md) for detailed Docker deployment instructions.

## 📊 Usage Guide

### 1. Data Input Format

The tool accepts JSON data in the following structure:

```json
[
  {
    "ip": "5.141.96.34",
    "country": "Russian Federation",
    "city": "Uray",
    "latitude": 60.13044,
    "longitude": 64.78896,
    "port": 22,
    "ssh_info": "Product: OpenSSH, Version: 7.4p1 Debian 10+deb9u6astra6, Type: ssh-rsa",
    "timestamp": "2025-08-12T22:10:31.501991"
  }
]
```

### 2. Required Fields
- `ip`: Target IP address
- `latitude`: Geographical latitude coordinate
- `longitude`: Geographical longitude coordinate
- `port`: Service port number
- `country`: Country name
- `city`: City name

### 3. Optional Fields
- `ssh_info`: SSH service information string
- `timestamp`: Discovery timestamp (ISO format)

### 4. Step-by-Step Workflow

1. **Load Sample Data**: Click "📋 Load Sample" to see example data
2. **Import Your Data**: Paste JSON data into the textarea
3. **Generate Map**: Click "🗺️ Generate Map" to visualize
4. **Analyze Results**: Review statistics and interact with map markers
5. **Clear Data**: Use "🗑️ Clear All" to reset the interface

## 🔧 Integration Examples

### Shodan Integration
```python
import shodan
import json

api = shodan.Shodan('YOUR_API_KEY')
query = 'product:"OpenSSH" "astra"'

results = []
for result in api.search_cursor(query):
    data = {
        'ip': result['ip_str'],
        'country': result.get('location', {}).get('country_name', 'Unknown'),
        'city': result.get('location', {}).get('city', 'Unknown'),
        'latitude': result.get('location', {}).get('latitude'),
        'longitude': result.get('location', {}).get('longitude'),
        'port': result.get('port'),
        'ssh_info': result.get('ssh', {}).get('fingerprint', 'N/A'),
        'timestamp': result.get('timestamp')
    }
    results.append(data)

# Export for geo mapper
with open('astra_systems.json', 'w') as f:
    json.dump(results, f, indent=2)
```

### Nmap Integration
```bash
# Scan and export results
nmap -sS -O -p22,80,443,2222 --script ssh-hostkey,ssh2-enum-algos \
     -oX scan_results.xml target_range

# Convert XML to JSON (using custom script)
python nmap_to_geo.py scan_results.xml > geo_data.json
```

## 🎨 Customization

### Color Schemes
Modify threat level colors in the JavaScript section:
```javascript
function getMarkerColor(threatLevel) {
    const colors = {
        1: '#3742fa',  // Low - Blue
        2: '#2ed573',  // Medium - Green  
        3: '#ffa502',  // High - Orange
        4: '#ff4757'   // Critical - Red
    };
    return colors[threatLevel] || '#747d8c';
}
```

### Risk Scoring
Customize threat assessment logic:
```javascript
function getThreatLevel(data) {
    let score = 0;
    
    // Add custom scoring rules
    if (data.port === 22) score += 1;
    if (data.ssh_info.includes('vulnerable_version')) score += 3;
    
    return Math.min(score, 4);
}
```

## 🛡️ Security Considerations

### Responsible Usage
- **Research Only**: Use for legitimate security research and system inventory
- **Data Privacy**: Ensure compliance with local data protection regulations
- **Ethical Scanning**: Only scan systems you own or have explicit permission to test
- **Rate Limiting**: Implement appropriate delays when collecting data

### Data Sanitization
- Validate all input JSON data
- Sanitize coordinates to prevent injection attacks
- Implement CSP headers when deploying publicly

## 📱 Browser Compatibility

| Browser | Version | Support |
|---------|---------|---------|
| Chrome | 80+ | ✅ Full |
| Firefox | 75+ | ✅ Full |
| Safari | 13+ | ✅ Full |
| Edge | 80+ | ✅ Full |

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a Pull Request

### Development Guidelines
- Follow existing code style and structure
- Test across multiple browsers
- Update documentation for new features
- Ensure responsive design compatibility

## 🐳 Docker Deployment

For production deployment, use Docker:

```bash
# Build and run with docker-compose
docker-compose up -d

# Or build manually
docker build -t astra-geo-mapper .
docker run -d -p 8080:80 astra-geo-mapper
```

The Docker image includes:
- ✅ Security headers configured in nginx
- ✅ Non-root user execution
- ✅ Read-only filesystem
- ✅ Health checks
- ✅ Minimal Alpine-based image (~15-20 MB)

See [README_DOCKER.md](README_DOCKER.md) for complete Docker documentation.

## 🔒 Security & CI/CD

### Pre-commit Hooks

The repository includes pre-commit hooks for:
- Secret detection (detect-secrets)
- Code quality checks
- File validation
- Security header verification

Install with: `make install`

### GitHub Actions

Automated CI/CD workflows:
- **Security Scanning**: Secret detection, security header checks
- **Docker Build**: Automated Docker image building and testing
- **Code Quality**: Pre-commit hooks, linting, validation

Workflows run on:
- Push to `main` branch
- Pull requests to `main`
- Tagged releases

### Security Features

- ✅ XSS protection (input sanitization)
- ✅ Content Security Policy (CSP)
- ✅ Subresource Integrity (SRI)
- ✅ Security headers (X-Frame-Options, etc.)
- ✅ Input validation
- ✅ Secret detection in CI/CD

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues**: Report bugs via [GitHub Issues](https://github.com/BuildAndDestroy/astra-geo-mapper/issues)
- **Discussions**: Join conversations in [Discussions](https://github.com/BuildAndDestroy/astra-geo-mapper/discussions)
- **Documentation**: Check the [Wiki](https://github.com/BuildAndDestroy/astra-geo-mapper/wiki) for detailed guides

## 📊 Project Stats

![GitHub stars](https://img.shields.io/github/stars/BuildAndDestroy/astra-geo-mapper?style=social)
![GitHub forks](https://img.shields.io/github/forks/BuildAndDestroy/astra-geo-mapper?style=social)
![GitHub issues](https://img.shields.io/github/issues/BuildAndDestroy/astra-geo-mapper)

## 🙏 Acknowledgments

- [Leaflet.js](https://leafletjs.com/) for interactive mapping capabilities
- [CARTO](https://carto.com/) for dark theme map tiles
- [Shodan](https://shodan.io/) for network intelligence inspiration
- The cybersecurity research community for continuous innovation

---

**⚠️ Disclaimer**: This tool is intended for educational and authorized security research purposes only. Users are responsible for ensuring compliance with applicable laws and regulations.
