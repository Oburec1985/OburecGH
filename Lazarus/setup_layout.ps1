# Lazarus layout configuration setup script
$configPath = "$env:LOCALAPPDATA\lazarus\environmentoptions.xml"
if (-not (Test-Path $configPath)) {
    Write-Host "Lazarus configuration file not found at: $configPath" -ForegroundColor Red
    Exit
}

# Backup configuration
$backupPath = "$configPath.bak"
Copy-Item $configPath $backupPath -Force
Write-Host "Created backup at: $backupPath" -ForegroundColor Green

# Load XML
[xml]$xml = Get-Content $configPath

# Find Desktop2 (Name="default docked")
$desktop = $xml.CONFIG.Desktops.ChildNodes | Where-Object { $_.Name -eq "default docked" }
if ($null -eq $desktop) {
    Write-Host "Section 'default docked' not found in configuration." -ForegroundColor Red
    Exit
}

# Update Watches Visibility
$watches = $desktop.Watches
if ($null -ne $watches) {
    if ($null -eq $watches.Visible) {
        $visNode = $xml.CreateElement("Visible")
        $visNode.SetAttribute("Value", "True")
        [void]$watches.AppendChild($visNode)
    } else {
        $watches.Visible.SetAttribute("Value", "True")
    }
}

# Update CallStack Visibility
$callStack = $desktop.CallStack
if ($null -ne $callStack) {
    if ($null -eq $callStack.Visible) {
        $visNode = $xml.CreateElement("Visible")
        $visNode.SetAttribute("Value", "True")
        [void]$callStack.AppendChild($visNode)
    } else {
        $callStack.Visible.SetAttribute("Value", "True")
    }
}

# Replace AnchorDocking block
$anchorDocking = $desktop.AnchorDocking
if ($null -ne $anchorDocking) {
    [void]$desktop.RemoveChild($anchorDocking)
}

# Create new AnchorDocking node with flat constraints layout
$newAnchorDockingXml = @"
      <AnchorDocking>
        <Version Value="1"/>
        <MainConfig>
          <Nodes ChildCount="1">
            <Item1 Name="MainIDE" Type="CustomSite" WindowState="Maximized" Monitor="0" ChildCount="1" PixelsPerInch="144">
              <Bounds Left="-11" Top="-11" Width="1920" Height="944">
                <WorkArea>
                  <Rect Right="1920" Bottom="1008"/>
                </WorkArea>
              </Bounds>
              <Item1 Name="AnchorDockSite1" Type="Layout" Monitor="0" ChildCount="9" PixelsPerInch="144">
                <Bounds Top="82" Width="1920" Height="862"/>
                <Anchors Align="Bottom"/>
                <!-- Item1: Watches (Left-Top) -->
                <Item1 Name="Watches" Type="Control" Monitor="0" PixelsPerInch="144">
                  <Bounds Width="350" Height="450"/>
                  <Anchors Right="AnchorDockSplitter1" Bottom="AnchorDockSplitter2"/>
                </Item1>
                <!-- Item2: CallStack (Left-Bottom) -->
                <Item2 Name="CallStack" Type="Control" Monitor="0" PixelsPerInch="144">
                  <Bounds Top="452" Width="350" Height="410"/>
                  <Anchors Right="AnchorDockSplitter1" Top="AnchorDockSplitter2"/>
                </Item2>
                <!-- Item3: Left Horizontal Splitter -->
                <Item3 Name="AnchorDockSplitter2" Type="SplitterHorizontal" Monitor="0" PixelsPerInch="144">
                  <Bounds Top="450" Width="350" Height="2"/>
                  <Anchors Right="AnchorDockSplitter1"/>
                </Item3>
                <!-- Item4: Left Vertical Splitter -->
                <Item4 Name="AnchorDockSplitter1" Type="SplitterVertical" Monitor="0" PixelsPerInch="144">
                  <Bounds Left="350" Width="2" Height="862"/>
                </Item4>
                <!-- Item5: SourceNotebook (Center-Top) -->
                <Item5 Name="SourceNotebook" Type="Control" Monitor="0" PixelsPerInch="144">
                  <Bounds Left="352" Width="1216" Height="680"/>
                  <Anchors Left="AnchorDockSplitter1" Right="AnchorDockSplitter3" Bottom="AnchorDockSplitter4"/>
                  <Header Position="left"/>
                </Item5>
                <!-- Item6: MessagesView (Center-Bottom) -->
                <Item6 Name="MessagesView" Type="Control" Monitor="0" PixelsPerInch="144">
                  <Bounds Left="352" Top="682" Width="1216" Height="180"/>
                  <Anchors Left="AnchorDockSplitter1" Top="AnchorDockSplitter4" Right="AnchorDockSplitter3"/>
                </Item6>
                <!-- Item7: Center Horizontal Splitter -->
                <Item7 Name="AnchorDockSplitter4" Type="SplitterHorizontal" Monitor="0" PixelsPerInch="144">
                  <Bounds Left="352" Top="680" Width="1216" Height="2"/>
                  <Anchors Left="AnchorDockSplitter1" Right="AnchorDockSplitter3"/>
                </Item7>
                <!-- Item8: Right Vertical Splitter -->
                <Item8 Name="AnchorDockSplitter3" Type="SplitterVertical" Monitor="0" PixelsPerInch="144">
                  <Bounds Left="1568" Width="2" Height="862"/>
                </Item8>
                <!-- Item9: ProjectInspector (Right) -->
                <Item9 Name="ProjectInspector" Type="Control" Monitor="0" PixelsPerInch="144">
                  <Bounds Left="1570" Width="350" Height="862"/>
                  <Anchors Left="AnchorDockSplitter3"/>
                </Item9>
              </Item1>
            </Item1>
          </Nodes>
        </MainConfig>
        <Restores Count="0"/>
        <Settings DragThreshold="2" FloatingWindowsOnTop="True" HeaderStyle="ThemedCaption" SplitterWidth="2"/>
      </AnchorDocking>
"@

$importedNode = $xml.ImportNode(([xml]$newAnchorDockingXml).DocumentElement, $true)
[void]$desktop.AppendChild($importedNode)

# Save XML
$xml.Save($configPath)
Write-Host "Lazarus layout configuration updated successfully!" -ForegroundColor Green
