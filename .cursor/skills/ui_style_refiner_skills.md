# 🎨 UI Style Refiner Skills

## Language Separation (언어 구분)
**Internal Processing (Agent reads)**: All instructions, logic, and internal operations are in English.
**User-Facing Content (User sees)**: All explanations, code comments, examples, and responses shown to users are in Korean.

## Overview
This skill provides core functions for the UI Style Refiner agent. It includes functions for style value calculation, color palette management, consistency verification, accessibility verification, multi-screen synchronization, and Material Design 3 compliance checking.

**한글 설명 (사용자용)**: 이 스킬은 UI Style Refiner가 사용하는 핵심 기능들을 제공합니다. 스타일 값 계산, 색상 팔레트 관리, 일관성 검증, 접근성 검증, 다중 화면 동기화, Material Design 3 준수 확인 등의 기능을 포함합니다.

---

## Skills

### 1. Analyze Style Refinement Requirements
**Purpose**: Understand user requirements for UI style refinement

**Input**: 
- User request text
- Target screens/components
- Specific style adjustments needed (colors, spacing, alignment, etc.)
- Scope (single component vs multiple screens)

**Output**: 
- Refinement type classification (color, spacing, alignment, layout, etc.)
- Target files identification (ALL related files, not just mentioned ones)
- Current style values
- Required changes
- Consistency requirements
- **Learned pattern match** (if applicable)

**Process**:
1. Parse request to identify refinement type
2. **Check learned patterns** - Does this match priority colors, multi-line text, vertical centering patterns?
3. Extract target components/screens
4. **Use grep to find ALL occurrences** of related style properties
5. Identify current style values
6. Determine required changes
7. Assess scope and synchronization needs
8. **List ALL files that need updates** (not just the mentioned one)

**Template (for agents, in English)**:
```
Style Refinement Requirements:
- Type: {color/spacing/alignment/layout/multi}
- Targets: {component_list}
- Current Values: {current_values}
- Required Changes: {required_changes}
- Scope: {single/multiple}
- Sync Needed: {yes/no}
```

---

### 2. Research Material Design 3 Guidelines (Indexing & Docs First)
**Purpose**: Find Material Design 3 guidelines using Indexing & Docs as primary source

**Input**:
- Refinement type
- Specific style property (spacing, color, typography, etc.)
- Component type

**Output**:
- Material Design 3 guidelines from Flutter_docs
- Spacing system values (4dp, 8dp, 16dp, 24dp, 32dp)
- Color system and accessibility guidelines
- Typography scale and line height guidelines
- Component-specific styling guidelines

**Priority Order**:
1. **Indexing & Docs (Primary)**: Flutter_docs, Material Design 3 가이드
2. **MCP Context7 (Secondary)**: 최신 Material Design 3 업데이트 확인
3. **Codebase Search (Tertiary)**: 프로젝트 내 실제 스타일 패턴

**Process**:
1. Check Flutter_docs (Indexing & Docs) for Material Design 3 guidelines
2. Check Material Design 3 spacing system
3. Check Material Design 3 color system and accessibility
4. Use MCP Context7 if Indexing & Docs insufficient
5. Search codebase for existing style patterns

**Template (for agents, in English)**:
```
Material Design 3 Research:
- Primary (Indexing & Docs): {guidelines_found}
- Secondary (MCP Context7): {latest_updates}
- Tertiary (Codebase): {existing_patterns}
- Selected Guidelines: {chosen_guidelines} - Reason: {reason}
```

---

### 3. Check Project Style Patterns (Deep Discovery)
**Purpose**: Understand project structure and existing style patterns

**Input**:
- Deep discovery report location
- Style refinement requirements

**Output**:
- Project structure information
- Existing style patterns
- Color palette definitions
- Style conventions
- Component styling approach

**Process**:
1. Check for existing deep discovery report in `.cursor/docs/deep-discovery/`
2. Extract style-related information from report
3. Identify color palette definitions
4. Understand spacing and layout conventions
5. Check existing component patterns

**Template (for agents, in English)**:
```
Project Style Patterns:
- Color Palette: {color_definitions}
- Spacing System: {spacing_values}
- Layout Conventions: {layout_patterns}
- Component Patterns: {component_styles}
- Style Constants: {style_constants}
```

---

### 4. Calculate Style Values
**Purpose**: Calculate appropriate style values based on Material Design 3 and project conventions

**Input**:
- Refinement type
- Material Design 3 guidelines
- Project style conventions
- Screen size considerations
- Component requirements

**Output**:
- Calculated spacing values (padding, margin)
- Color values (maintaining consistency)
- Alignment offsets
- Font sizes and line heights
- Multi-line text layout calculations

**Process**:
1. Apply Material Design 3 spacing system (4dp, 8dp, 16dp, 24dp, 32dp)
2. Calculate responsive values based on screen size
3. Determine alignment offsets for proper centering
4. Calculate multi-line text spacing
5. Ensure values maintain consistency

**Template (for agents, in English)**:
```
Style Value Calculation:
- Spacing: {calculated_spacing} (Material Design 3: {md3_value})
- Color: {calculated_color} (Consistent with: {related_colors})
- Alignment: {calculated_alignment} (Offset: {offset_value})
- Typography: {calculated_typography} (Line Height: {line_height})
```

---

### 5. Verify Color Consistency
**Purpose**: Ensure color palette consistency across all screens and components

**Input**:
- Color changes
- Project color palette
- All related components

**Output**:
- Consistency verification result
- List of files that need updates
- Color palette synchronization plan

**Process**:
1. Identify all components using the color
2. Check if color matches project palette
3. Verify consistency across all identified locations
4. Plan synchronization updates
5. Document color usage

**Template (for agents, in English)**:
```
Color Consistency Verification:
- Color: {color_value}
- Used In: {file_list}
- Consistent: {yes/no}
- Needs Update: {file_list}
- Palette Match: {yes/no}
```

---

### 6. Verify Accessibility Compliance
**Purpose**: Verify color contrast and accessibility standards

**Input**:
- Color values (foreground and background)
- Text sizes
- Component types

**Output**:
- Color contrast ratio
- WCAG 2.1 AA compliance status
- Text readability assessment
- Touch target size verification
- Accessibility recommendations

**Process**:
1. Calculate color contrast ratio (foreground vs background)
2. Verify WCAG 2.1 AA standards (4.5:1 for normal text, 3:1 for large text)
3. Check text readability
4. Verify touch target sizes (minimum 48dp)
5. Provide recommendations if needed

**Template (for agents, in English)**:
```
Accessibility Verification:
- Contrast Ratio: {ratio} (WCAG AA: {compliant/not_compliant})
- Text Readability: {good/fair/poor}
- Touch Target: {size}dp (Minimum: 48dp - {compliant/not_compliant})
- Recommendations: {recommendations}
```

---

### 7. Synchronize Styles Across Screens
**Purpose**: Apply style changes consistently across multiple screens/components

**Input**:
- Style changes
- List of related files (ALL files found via grep and codebase search)
- Synchronization scope

**Output**:
- Updated files list (ALL files, not just mentioned ones)
- Synchronization verification
- Consistency confirmation
- Verification that no files were missed

**Process**:
1. **Identify ALL files** that need updates using grep and codebase search
2. **Apply changes to ALL files in batch** (not one by one)
3. Verify consistency after changes
4. **Use grep again** to check for any missed locations
5. Document synchronization with complete file list
6. **For priority colors**: Always update all 4 files (calendar_widget, calendar_date_cell, todo_item, todo_input_screen)

**Template (for agents, in English)**:
```
Style Synchronization:
- Files Updated: {file_list}
- Changes Applied: {changes_list}
- Consistency Verified: {yes/no}
- Missed Locations: {none/list}
```

---

### 8. Generate Refinement Code
**Purpose**: Generate code modifications with proper style values

**Input**:
- Calculated style values
- Target file
- Current code structure

**Output**:
- Modified code with new style values
- Korean comments explaining changes
- Proper formatting and structure

**Process**:
1. Read target file
2. Identify style-related code sections
3. Apply calculated style values
4. Add Korean comments
5. Maintain code structure and formatting

**Template (for agents, in English)**:
```
Code Generation:
- File: {file_path}
- Sections Modified: {sections_list}
- Values Applied: {values_list}
- Comments Added: {yes/no}
- Formatting: {preserved/modified}
```

---

### 9. Verify Material Design 3 Compliance
**Purpose**: Verify refined styles comply with Material Design 3 guidelines

**Input**:
- Refined style values
- Material Design 3 guidelines
- Component type

**Output**:
- Compliance status for each guideline
- Non-compliance issues (if any)
- Recommendations for improvement

**Process**:
1. Check spacing system compliance
2. Verify color system compliance
3. Check typography scale compliance
4. Verify component-specific guidelines
5. Document compliance status

**Template (for agents, in English)**:
```
Material Design 3 Compliance:
- Spacing System: {compliant/not_compliant} - {details}
- Color System: {compliant/not_compliant} - {details}
- Typography: {compliant/not_compliant} - {details}
- Component Guidelines: {compliant/not_compliant} - {details}
- Overall: {compliant/not_compliant}
```

---

### 10. Document Style Changes
**Purpose**: Document all style changes for reference and consistency

**Input**:
- All style changes made
- Files modified
- Rationale for changes

**Output**:
- Style change documentation
- Updated style guide (if applicable)
- Change summary

**Process**:
1. List all changes made
2. Document rationale for each change
3. Reference Material Design 3 guidelines
4. Update project style guide if needed
5. Create change summary

**Template (for agents, in English)**:
```
Style Change Documentation:
- Changes: {changes_list}
- Files: {file_list}
- Rationale: {rationale_list}
- Guidelines: {guidelines_referenced}
- Style Guide Updated: {yes/no}
```

---

## Usage Examples

### Example 1: Color Palette Synchronization
```
Input: "모든 화면에 파스텔 색상 적용"
Process:
1. Analyze requirements → Color change, multiple screens
2. Research Material Design 3 → Color system guidelines
3. Check project patterns → Existing color palette
4. Calculate values → New color values maintaining consistency
5. Verify consistency → All related components identified
6. Synchronize → Apply to all identified files
7. Verify accessibility → Color contrast ratios
8. Document → Change summary
```

### Example 2: Spacing Refinement
```
Input: "우선순위 버튼 패딩 이쁘게 해줘"
Process:
1. Analyze requirements → Spacing adjustment, single component
2. Research Material Design 3 → Spacing system (4dp, 8dp, 16dp)
3. Check project patterns → Existing button spacing
4. Calculate values → Optimal padding values
5. Verify consistency → Check other buttons
6. Generate code → Apply new padding values
7. Verify compliance → Material Design 3 spacing system
8. Document → Change summary
```

---

## Integration with Agent

These skills are used by the UI Style Refiner agent in the following workflow:

1. **Request Analysis** → Skill 1 (Analyze Style Refinement Requirements)
2. **Guideline Research** → Skill 2 (Research Material Design 3 Guidelines)
3. **Project Pattern Check** → Skill 3 (Check Project Style Patterns)
4. **Value Calculation** → Skill 4 (Calculate Style Values)
5. **Consistency Verification** → Skill 5 (Verify Color Consistency)
6. **Accessibility Check** → Skill 6 (Verify Accessibility Compliance)
7. **Synchronization** → Skill 7 (Synchronize Styles Across Screens)
8. **Code Generation** → Skill 8 (Generate Refinement Code)
9. **Compliance Verification** → Skill 9 (Verify Material Design 3 Compliance)
10. **Documentation** → Skill 10 (Document Style Changes)

---

## Best Practices

1. **Always use Indexing & Docs first** for Material Design 3 guidelines
2. **Check deep discovery reports** for project style patterns
3. **Verify consistency** before and after changes
4. **Calculate values** based on Material Design 3 system
5. **Verify accessibility** for all color and text changes
6. **Synchronize** across all related components
7. **Document changes** for future reference
8. **Use Korean comments** in generated code
9. **Maintain code structure** when making changes
10. **Test visual results** after refinement
