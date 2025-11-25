# Android Testing Guide

## 🚀 Quick Start

### Run on Android Device:
```bash
flutter run
```

### Build APK:
```bash
flutter build apk --release
```

---

## ✅ Test Checklist

### 1. Auth Lock Screen
**Path:** Open app → PIN screen appears

**Test:**
- [ ] All number buttons (0-9) are clickable
- [ ] Backspace (⌫) button works
- [ ] Enter 4 digits → auto-verifies
- [ ] Wrong PIN → shows error + clears
- [ ] Correct PIN → navigates to dashboard
- [ ] Biometric button appears (if enabled)
- [ ] Screen fits without scrolling
- [ ] No cut-off elements
- [ ] Logo displays correctly

**Expected Behavior:**
- Smooth number entry
- Instant feedback
- No lag or freezing
- Clear error messages

---

### 2. Dashboard

**Test:**
- [ ] Logo displays in header
- [ ] Notification bell icon visible
- [ ] Quick add (⚡) button visible
- [ ] Notification badge shows count
- [ ] All buttons are clickable
- [ ] Pull to refresh works
- [ ] Smooth scrolling
- [ ] No layout overflow

**Tap Notification Bell:**
- [ ] Bottom sheet opens
- [ ] Shows notifications list
- [ ] Can swipe to dismiss
- [ ] "Mark all read" works
- [ ] Sheet closes properly

**Tap Quick Add (⚡):**
- [ ] Template selector opens
- [ ] Shows template grid
- [ ] Templates are clickable
- [ ] Selecting template works
- [ ] Sheet closes properly

---

### 3. Navigation

**Test:**
- [ ] Bottom navigation works
- [ ] All tabs accessible
- [ ] Smooth transitions
- [ ] No crashes

---

## 🐛 Common Issues & Fixes

### Issue: Buttons not clickable
**Fix:** ✅ Already fixed - using Material + InkWell

### Issue: Screen cut off
**Fix:** ✅ Already fixed - using Column + Spacer

### Issue: Notification badge not showing
**Check:**
1. NotificationService is in providers
2. Notifications exist in service
3. Badge widget is in dashboard

### Issue: Templates not loading
**Check:**
1. TemplateService is in providers
2. Database table exists
3. loadTemplates() is called

---

## 📱 Device-Specific Tests

### Small Screens (< 5.5")
- [ ] PIN screen fits
- [ ] Dashboard readable
- [ ] Buttons not too small

### Large Screens (> 6.5")
- [ ] Layout scales properly
- [ ] No excessive whitespace
- [ ] Touch targets appropriate

### Different Android Versions
- [ ] Android 10+
- [ ] Android 11+
- [ ] Android 12+
- [ ] Android 13+

---

## 🎯 Performance Tests

### Startup Time
- [ ] App opens < 2 seconds
- [ ] PIN screen appears quickly
- [ ] No white screen flash

### Navigation
- [ ] Tab switches < 100ms
- [ ] Screen transitions smooth
- [ ] No frame drops

### Memory
- [ ] No memory leaks
- [ ] Stable memory usage
- [ ] No crashes after extended use

---

## 🔍 Debug Commands

### Check logs:
```bash
flutter logs
```

### Check for errors:
```bash
flutter analyze
```

### Profile performance:
```bash
flutter run --profile
```

### Check app size:
```bash
flutter build apk --analyze-size
```

---

## 📊 Expected Results

### Auth Screen:
- ✅ Clean, modern design
- ✅ All buttons work
- ✅ Fast response
- ✅ No layout issues

### Dashboard:
- ✅ Notification badge visible
- ✅ Quick add accessible
- ✅ Smooth scrolling
- ✅ All features work

### Overall:
- ✅ No crashes
- ✅ Good performance
- ✅ Intuitive UX
- ✅ Professional look

---

## 🚨 Report Issues

If you find any issues:

1. **Note the device:** Model, Android version
2. **Describe the issue:** What happened vs expected
3. **Steps to reproduce:** How to trigger the issue
4. **Screenshots:** If possible
5. **Logs:** Run `flutter logs` and copy relevant errors

---

## ✨ Success Criteria

App is ready for release when:
- ✅ All checklist items pass
- ✅ No critical bugs
- ✅ Smooth performance
- ✅ Good user experience
- ✅ Works on multiple devices

---

Happy Testing! 🎉
