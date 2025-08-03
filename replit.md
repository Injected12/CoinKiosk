# FiveM ESX Coin Shop System

## Overview

This is a FiveM script for ESX framework that implements a complete coin-based economy system with an interactive shop. The system allows administrators to give coins to players and provides an NPC-based shop where players can purchase items using their coins. The project includes both player-facing shop interface and admin management tools with modern web-based UIs.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Core Components

**ESX Integration**
- Built specifically for ESX framework integration
- Coins are stored server-side tied to player identifiers to prevent theft through inventory raids
- Uses ESX's player data management system for persistent coin storage

**Client-Server Architecture**
- Client-side Lua handles NPC spawning, interaction detection, and UI management
- Server-side Lua manages coin transactions, admin commands, and data persistence
- Web-based UI using HTML/CSS/JavaScript for both shop and admin interfaces

**NPC System**
- Static NPC positioned at specific coordinates with custom model
- 3D text display above NPC showing "COIN butik"
- Interaction detection using ESX's target system or proximity-based key press detection

**User Interface Design**
- Modern dark theme with neon green accents (#00ff88)
- Responsive grid-based product display
- Modal-based forms for admin product management
- Clean animations and transitions for professional feel

**Data Management**
- JSON-based product storage system
- Real-time synchronization between admin changes and player shop view
- Persistent coin balances tied to player identifiers

### Command System

**Admin Commands**
- `/givecoins [id] [amount]` - Allows administrators to give coins to players
- Admin-only product management through dedicated UI interface

**Player Commands**
- `/coinstatus` - Displays current coin balance in chat notification

### Security Model

**Anti-Exploitation Measures**
- Server-side validation for all coin transactions
- Admin permission checks for coin distribution
- Coins stored outside inventory system to prevent theft
- Input sanitization for admin product management

**Permission System**
- Role-based access control for admin functions
- ESX group integration for command permissions

## External Dependencies

**Required Framework**
- ESX (Extended) framework for FiveM
- ESX player management system
- ESX notification system

**Game Dependencies**
- FiveM client/server environment
- GTA V game assets for NPC models and positioning

**Web Technologies**
- HTML5 for UI structure
- CSS3 with modern features (flexbox, animations, gradients)
- Vanilla JavaScript for UI interactions and NUI communication

**Potential Database Integration**
- The system is designed to work with ESX's existing database structure
- May require database table modifications to store coin balances
- Product data currently stored in JSON but could be migrated to database tables

**Asset Dependencies**
- Custom NPC model: `a_m_m_soucent_03`
- Specific coordinate positioning system
- ESX's built-in notification and UI systems