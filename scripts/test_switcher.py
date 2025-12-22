#!/usr/bin/env python3
"""
Test script for Pwnagotchi Mode Switcher
Tests basic functionality without requiring root access or actual Pwnagotchi installation
"""

import sys
import os
import unittest
from unittest.mock import patch, MagicMock
from pathlib import Path
import subprocess

# Add current directory to path to import the switcher
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Import the switcher module by loading it dynamically
import importlib.util
spec = importlib.util.spec_from_file_location(
    "pwnagotchi_switcher", 
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "pwnagotchi-switcher.py")
)
switcher_module = importlib.util.module_from_spec(spec)
sys.modules['pwnagotchi_switcher'] = switcher_module
spec.loader.exec_module(switcher_module)

class TestPwnagotchiSwitcher(unittest.TestCase):
    """Test cases for PwnagotchiSwitcher class"""
    
    def setUp(self):
        """Set up test fixtures"""
        self.switcher = switcher_module.PwnagotchiSwitcher()
    
    @patch('os.path.exists')
    def test_detect_auto_mode(self, mock_exists):
        """Test AUTO mode detection"""
        mock_exists.return_value = True
        mode = self.switcher._detect_current_mode()
        self.assertEqual(mode, "AUTO")
    
    @patch('os.path.exists')
    @patch('subprocess.run')
    def test_detect_manu_mode(self, mock_run, mock_exists):
        """Test MANU mode detection"""
        mock_exists.return_value = False
        mock_result = MagicMock()
        mock_result.stdout = "USB Ethernet RNDIS Gadget"
        mock_run.return_value = mock_result
        mode = self.switcher._detect_current_mode()
        self.assertEqual(mode, "MANU")
    
    @patch('os.path.exists')
    @patch('subprocess.run')
    def test_detect_ai_mode(self, mock_run, mock_exists):
        """Test AI mode detection"""
        mock_exists.return_value = False
        mock_result = MagicMock()
        mock_result.stdout = "USB Device"
        mock_run.return_value = mock_result
        mode = self.switcher._detect_current_mode()
        self.assertEqual(mode, "AI")
    
    @patch('pathlib.Path.touch')
    def test_switch_to_auto(self, mock_touch):
        """Test switching to AUTO mode"""
        result = self.switcher.switch_to_auto()
        self.assertTrue(result)
        mock_touch.assert_called_once()
    
    @patch('os.path.exists')
    @patch('os.remove')
    def test_switch_to_ai(self, mock_remove, mock_exists):
        """Test switching to AI mode"""
        mock_exists.return_value = True
        result = self.switcher.switch_to_ai()
        self.assertTrue(result)
        mock_remove.assert_called_once()
    
    def test_switch_to_manu(self):
        """Test switching to MANU mode"""
        result = self.switcher.switch_to_manu()
        self.assertTrue(result)
    
    @patch('subprocess.run')
    @patch('os.path.exists')
    def test_get_status(self, mock_exists, mock_run):
        """Test status retrieval"""
        mock_exists.return_value = False
        mock_result = MagicMock()
        mock_result.stdout = "active\n"
        mock_run.return_value = mock_result
        result = self.switcher.get_status()
        self.assertTrue(result)
    
    @patch('subprocess.run')
    def test_restart_service_success(self, mock_run):
        """Test successful service restart"""
        result = self.switcher.restart_service()
        self.assertTrue(result)
        mock_run.assert_called_once()
    
    @patch('subprocess.run')
    def test_restart_service_failure(self, mock_run):
        """Test failed service restart"""
        mock_run.side_effect = subprocess.CalledProcessError(1, 'systemctl')
        result = self.switcher.restart_service()
        self.assertFalse(result)


class TestMainFunction(unittest.TestCase):
    """Test cases for main function"""
    
    @patch('os.geteuid')
    @patch('sys.argv', ['pwnagotchi-switcher.py', 'status'])
    @patch.object(switcher_module.PwnagotchiSwitcher, 'get_status')
    def test_status_command_no_root(self, mock_status, mock_geteuid):
        """Test status command can run without root"""
        mock_geteuid.return_value = 1000  # Non-root user
        mock_status.return_value = True
        
        try:
            switcher_module.main()
        except SystemExit:
            self.fail("Status command should not require root")
    
    @patch('os.geteuid')
    @patch('sys.argv', ['pwnagotchi-switcher.py', 'auto'])
    def test_auto_command_requires_root(self, mock_geteuid):
        """Test auto command requires root"""
        mock_geteuid.return_value = 1000  # Non-root user
        
        with self.assertRaises(SystemExit) as cm:
            switcher_module.main()
        self.assertEqual(cm.exception.code, 1)


def run_tests():
    """Run all tests"""
    print("=" * 60)
    print("Running Pwnagotchi Mode Switcher Tests")
    print("=" * 60)
    print()
    
    # Create test suite
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    # Add tests
    suite.addTests(loader.loadTestsFromTestCase(TestPwnagotchiSwitcher))
    suite.addTests(loader.loadTestsFromTestCase(TestMainFunction))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    print()
    print("=" * 60)
    if result.wasSuccessful():
        print("All tests passed!")
    else:
        print("Some tests failed!")
    print("=" * 60)
    
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    sys.exit(run_tests())
