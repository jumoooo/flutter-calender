## Caching Strategy

### Generated Report Caching
- **Cache Location**: `.cursor/docs/deep-discovery/deep-discovery_{ref}_{depth}_{mode}.json`
- **Cache Key**: `{ref}_{depth}_{mode}`
- **Cache Validity**: 
  - Same project/branch: 7 days
  - Different branch: Invalid
  - Different project: Invalid
- **Cache Usage**: 
  - Always save generated reports for reuse
  - Other agents check for existing reports before requesting new discovery
- **Cache Invalidation**: 
  - Report older than 7 days
  - Branch/project change detected
  - Explicit user request for refresh

### Project Structure Analysis Caching
- **Cache Duration**: Session-based
- **Cache Key**: Project root + analysis scope
- **Cache Usage**: 
  - Cache directory structure analysis within session
  - Reuse for multiple reports in same session
- **Cache Invalidation**: 
  - Session ends
  - Project structure changes detected

### Tech Stack Detection Caching
- **Cache Duration**: Until package files change
- **Cache Key**: pubspec.yaml hash (or equivalent)
- **Cache Usage**: 
  - Cache tech stack detection results
  - Reuse until package files modified
- **Cache Invalidation**: 
  - pubspec.yaml modified
  - package.json modified (if applicable)
