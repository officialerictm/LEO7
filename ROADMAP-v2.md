# Leonardo AI Universal - Development Roadmap v2.0
*Based on User Testing Feedback - June 3, 2025*

## 🔥 Critical Fixes (Week 1: June 3-7)

### Day 1-2: Terminal Output & UI Polish
- [ ] **Fix escaped color codes** showing as `\033[0;36m` instead of actual colors
  - Issue: Colors not rendering in submenus
  - Solution: Ensure all output uses proper terminal redirection
- [ ] **Clean menu transitions**
  - Clear screen properly between menus
  - Fix "Back to Main Menu" leaving artifacts
- [ ] **Fix double "Press Enter" prompts**

### Day 3-4: Model Management UX
- [ ] **Model Registry Integration**
  - Connect to Ollama/HuggingFace model lists
  - Populate "List Available Models" with real data
  - Make "Search Models" actually search available models
- [ ] **User-Friendly Input Guidance**
  - Download Model: Show examples (e.g., "Enter: llama3:8b, mistral:7b, or 'llama' to see all llama models")
  - Model Information: Auto-list installed models if only one exists
  - Add help text for all input prompts
- [ ] **Smart Model Selection**
  - If user types "llama", show all llama variants
  - Support partial matching
  - Number-based selection from lists

### Day 5: USB Management Improvements
- [ ] **Interactive USB Selection**
  - Replace text input with menu selection for USB devices
  - Color coding: 🟢 Green = Leonardo installed, 🔵 Blue = Good candidate, ⚫ Gray = Not recommended
- [ ] **Fix USB Health Check Errors**
  - Create missing directories/files
  - Handle missing commands gracefully
  - Show meaningful health metrics

## 🚀 Feature Completion (Week 2: June 10-14)

### Core Functionality
- [ ] **System Tests Implementation**
  - Actually run system checks
  - Show progress indicators
  - Display results clearly
- [ ] **Web Interface**
  - Implement `start_web_server` function
  - Auto-open browser
  - Basic web UI with model chat interface
- [ ] **Deploy to USB**
  - Complete deployment workflow
  - Progress indicators
  - Verification steps

### Enhanced UX
- [ ] **Joey Bagofdonuts Mode**
  - Guided setup wizard for first-time users
  - Auto-detect best options
  - Tooltips and help everywhere
- [ ] **Power User Features**
  - Keyboard shortcuts display
  - Batch operations
  - Command history

## 📊 Immediate Priority Order

### Sprint 1 (This Week)
```
1. Fix color output issues (2 hours)
2. Connect model registry (4 hours)
3. Improve input prompts (2 hours)
4. USB device selection menu (3 hours)
5. System tests implementation (2 hours)
6. Web server basic implementation (4 hours)
```

### Sprint 2 (Next Week)
```
1. Model download with progress (4 hours)
2. USB deployment flow (6 hours)
3. Dashboard real-time updates (4 hours)
4. Settings persistence (2 hours)
5. Error recovery (3 hours)
```

## 🎯 Success Metrics

### Week 1 Goals
- ✅ All menus display correctly with colors
- ✅ Users can list and search real models
- ✅ USB selection is intuitive
- ✅ No error messages in normal flow
- ✅ Web interface launches

### Week 2 Goals
- ✅ Complete model download workflow
- ✅ USB deployment works end-to-end
- ✅ 90% of features implemented
- ✅ Ready for beta release

## 🔧 Technical Fixes Needed

### Immediate Code Fixes
```bash
# 1. Fix color output in submenus
# Change: echo -e "\033[0;36mText\033[0m"
# To: echo -e "${CYAN}Text${COLOR_RESET}"

# 2. Fix menu clearing
# Add proper clear before each submenu

# 3. Fix missing functions
# - start_web_server
# - check_system_requirements output
# - Model registry connection
```

### Architecture Improvements
1. **Standardize Input Methods**
   - Create reusable input functions with validation
   - Support both menu selection and text input
   - Always provide examples and help

2. **Error Handling**
   - Graceful fallbacks for missing commands
   - User-friendly error messages
   - Recovery suggestions

3. **Progress Feedback**
   - Use progress bars for long operations
   - Status messages for each step
   - Clear success/failure indicators

## 📝 User Experience Principles

### For Joey Bagofdonuts
- **Always provide examples** in input prompts
- **Auto-detect** when possible
- **Explain technical terms** inline
- **Guided mode** for complex operations

### For Power Users
- **Keyboard shortcuts** visible
- **Direct input** options
- **Batch operations** support
- **CLI arguments** for automation

## 🎉 Quick Wins (Do Today!)

1. **Fix color output** (30 min)
   ```bash
   # In all submenus, replace escaped sequences with color vars
   sed -i 's/\\033\[0;36m/${CYAN}/g' src/core/main.sh
   ```

2. **Add model registry** (1 hour)
   ```bash
   # Create default model list
   MODELS=(
     "llama3:8b|Llama 3 8B|4.5GB|Q4_0|Apache-2.0"
     "mistral:7b|Mistral 7B|4.1GB|Q4_0|Apache-2.0"
     "codellama:13b|Code Llama 13B|7.3GB|Q4_0|Custom"
   )
   ```

3. **Fix USB selection** (1 hour)
   - Convert to menu-based selection
   - Add color coding
   - Show recommendations

4. **Implement system tests** (30 min)
   - Check disk space
   - Verify dependencies
   - Test network connectivity

## 🚀 Release Plan

### v7.0.0-beta (June 7)
- Core functionality working
- Major bugs fixed
- Ready for community testing

### v7.0.0-rc1 (June 14)
- All features implemented
- Polish and refinement
- Documentation complete

### v7.0.0 (June 21)
- Production ready
- Tested by community
- Blog post and announcement

## 💡 Next Session Focus

**Tomorrow's Priority List:**
1. Fix all color output issues
2. Create working model list/search
3. Implement USB device selection menu
4. Add real system tests output
5. Create basic web server function

**Code We'll Write:**
- Model registry with real data
- USB device selector
- Web server launcher
- System test runner
- Input validation helpers
