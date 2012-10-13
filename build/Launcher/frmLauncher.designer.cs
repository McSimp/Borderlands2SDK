﻿namespace Launcher
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
            this.gbGamePath.SuspendLayout();
            this.SuspendLayout();
            // 
            // gbGamePath
            // 
            this.gbGamePath.Controls.Add(this.btnBrowse);
            this.gbGamePath.Controls.Add(this.txtGamePath);
            this.gbGamePath.Location = new System.Drawing.Point(12, 12);
            this.gbGamePath.Name = "gbGamePath";
            this.gbGamePath.Size = new System.Drawing.Size(392, 88);
            this.gbGamePath.TabIndex = 0;
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
            this.btnBrowse.TabIndex = 2;
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
            this.txtGamePath.TabIndex = 1;
            // 
            // btnLaunch
            // 
            this.btnLaunch.Image = ((System.Drawing.Image)(resources.GetObject("btnLaunch.Image")));
            this.btnLaunch.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnLaunch.Location = new System.Drawing.Point(12, 106);
            this.btnLaunch.Name = "btnLaunch";
            this.btnLaunch.Size = new System.Drawing.Size(392, 64);
            this.btnLaunch.TabIndex = 3;
            this.btnLaunch.Text = "Launch Game";
            this.btnLaunch.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
            this.btnLaunch.UseVisualStyleBackColor = true;
            this.btnLaunch.Click += new System.EventHandler(this.btnLaunch_Click);
            // 
            // frmLauncher
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(416, 182);
            this.Controls.Add(this.btnLaunch);
            this.Controls.Add(this.gbGamePath);
            this.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.Name = "frmLauncher";
            this.Text = "Borderlands 2 SDK Launcher";
            this.Load += new System.EventHandler(this.frmLauncher_Load);
            this.gbGamePath.ResumeLayout(false);
            this.gbGamePath.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.GroupBox gbGamePath;
        private System.Windows.Forms.Button btnBrowse;
        private System.Windows.Forms.TextBox txtGamePath;
        private System.Windows.Forms.Button btnLaunch;
    }
}

