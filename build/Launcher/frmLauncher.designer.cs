namespace Launcher
{
    partial class frmLauncher
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmLauncher));
            this.gbGamePath = new System.Windows.Forms.GroupBox();
            this.btnBrowse = new System.Windows.Forms.Button();
            this.txtGamePath = new System.Windows.Forms.TextBox();
            this.btnLaunch = new System.Windows.Forms.Button();
            this.msMenu = new System.Windows.Forms.MenuStrip();
            this.optionsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.disableAntiDebugToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.logAllProcessEventCallsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.disableCrashReportingToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.aboutToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.gbGamePath.SuspendLayout();
            this.msMenu.SuspendLayout();
            this.SuspendLayout();
            // 
            // gbGamePath
            // 
            this.gbGamePath.Controls.Add(this.btnBrowse);
            this.gbGamePath.Controls.Add(this.txtGamePath);
            this.gbGamePath.Location = new System.Drawing.Point(12, 27);
            this.gbGamePath.Name = "gbGamePath";
            this.gbGamePath.Size = new System.Drawing.Size(392, 88);
            this.gbGamePath.TabIndex = 1;
            this.gbGamePath.TabStop = false;
            this.gbGamePath.Text = "Game Path";
            // 
            // btnBrowse
            // 
            this.btnBrowse.Image = ((System.Drawing.Image)(resources.GetObject("btnBrowse.Image")));
            this.btnBrowse.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnBrowse.Location = new System.Drawing.Point(300, 52);
            this.btnBrowse.Name = "btnBrowse";
            this.btnBrowse.Size = new System.Drawing.Size(82, 27);
            this.btnBrowse.TabIndex = 3;
            this.btnBrowse.Text = "Browse";
            this.btnBrowse.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
            this.btnBrowse.UseVisualStyleBackColor = true;
            this.btnBrowse.Click += new System.EventHandler(this.btnBrowse_Click);
            // 
            // txtGamePath
            // 
            this.txtGamePath.Location = new System.Drawing.Point(8, 23);
            this.txtGamePath.Name = "txtGamePath";
            this.txtGamePath.Size = new System.Drawing.Size(374, 23);
            this.txtGamePath.TabIndex = 2;
            // 
            // btnLaunch
            // 
            this.btnLaunch.Image = ((System.Drawing.Image)(resources.GetObject("btnLaunch.Image")));
            this.btnLaunch.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnLaunch.Location = new System.Drawing.Point(12, 121);
            this.btnLaunch.Name = "btnLaunch";
            this.btnLaunch.Size = new System.Drawing.Size(392, 64);
            this.btnLaunch.TabIndex = 4;
            this.btnLaunch.Text = "Launch Game";
            this.btnLaunch.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
            this.btnLaunch.UseVisualStyleBackColor = true;
            this.btnLaunch.Click += new System.EventHandler(this.btnLaunch_Click);
            // 
            // msMenu
            // 
            this.msMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.optionsToolStripMenuItem,
            this.aboutToolStripMenuItem});
            this.msMenu.Location = new System.Drawing.Point(0, 0);
            this.msMenu.Name = "msMenu";
            this.msMenu.Size = new System.Drawing.Size(416, 24);
            this.msMenu.TabIndex = 0;
            this.msMenu.Text = "msMenu";
            // 
            // optionsToolStripMenuItem
            // 
            this.optionsToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.disableAntiDebugToolStripMenuItem,
            this.logAllProcessEventCallsToolStripMenuItem,
            this.disableCrashReportingToolStripMenuItem});
            this.optionsToolStripMenuItem.Name = "optionsToolStripMenuItem";
            this.optionsToolStripMenuItem.Size = new System.Drawing.Size(61, 20);
            this.optionsToolStripMenuItem.Text = "Options";
            // 
            // disableAntiDebugToolStripMenuItem
            // 
            this.disableAntiDebugToolStripMenuItem.Image = ((System.Drawing.Image)(resources.GetObject("disableAntiDebugToolStripMenuItem.Image")));
            this.disableAntiDebugToolStripMenuItem.Name = "disableAntiDebugToolStripMenuItem";
            this.disableAntiDebugToolStripMenuItem.Size = new System.Drawing.Size(207, 22);
            this.disableAntiDebugToolStripMenuItem.Text = "Disable Anti-Debug";
            this.disableAntiDebugToolStripMenuItem.Click += new System.EventHandler(this.disableAntiDebugToolStripMenuItem_Click);
            // 
            // logAllProcessEventCallsToolStripMenuItem
            // 
            this.logAllProcessEventCallsToolStripMenuItem.Image = ((System.Drawing.Image)(resources.GetObject("logAllProcessEventCallsToolStripMenuItem.Image")));
            this.logAllProcessEventCallsToolStripMenuItem.Name = "logAllProcessEventCallsToolStripMenuItem";
            this.logAllProcessEventCallsToolStripMenuItem.Size = new System.Drawing.Size(207, 22);
            this.logAllProcessEventCallsToolStripMenuItem.Text = "Log all ProcessEvent calls";
            this.logAllProcessEventCallsToolStripMenuItem.Click += new System.EventHandler(this.logAllProcessEventCallsToolStripMenuItem_Click);
            // 
            // disableCrashReportingToolStripMenuItem
            // 
            this.disableCrashReportingToolStripMenuItem.Image = ((System.Drawing.Image)(resources.GetObject("disableCrashReportingToolStripMenuItem.Image")));
            this.disableCrashReportingToolStripMenuItem.Name = "disableCrashReportingToolStripMenuItem";
            this.disableCrashReportingToolStripMenuItem.Size = new System.Drawing.Size(207, 22);
            this.disableCrashReportingToolStripMenuItem.Text = "Disable crash reporting";
            this.disableCrashReportingToolStripMenuItem.Click += new System.EventHandler(this.disableCrashReportingToolStripMenuItem_Click);
            // 
            // aboutToolStripMenuItem
            // 
            this.aboutToolStripMenuItem.Name = "aboutToolStripMenuItem";
            this.aboutToolStripMenuItem.Size = new System.Drawing.Size(52, 20);
            this.aboutToolStripMenuItem.Text = "About";
            this.aboutToolStripMenuItem.Click += new System.EventHandler(this.aboutToolStripMenuItem_Click);
            // 
            // frmLauncher
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(416, 192);
            this.Controls.Add(this.btnLaunch);
            this.Controls.Add(this.gbGamePath);
            this.Controls.Add(this.msMenu);
            this.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MainMenuStrip = this.msMenu;
            this.MaximizeBox = false;
            this.Name = "frmLauncher";
            this.Text = "Borderlands 2 SDK Launcher";
            this.Load += new System.EventHandler(this.frmLauncher_Load);
            this.gbGamePath.ResumeLayout(false);
            this.gbGamePath.PerformLayout();
            this.msMenu.ResumeLayout(false);
            this.msMenu.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.GroupBox gbGamePath;
        private System.Windows.Forms.Button btnBrowse;
        private System.Windows.Forms.TextBox txtGamePath;
        private System.Windows.Forms.Button btnLaunch;
        private System.Windows.Forms.MenuStrip msMenu;
        private System.Windows.Forms.ToolStripMenuItem aboutToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem optionsToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem disableAntiDebugToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem logAllProcessEventCallsToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem disableCrashReportingToolStripMenuItem;
    }
}

