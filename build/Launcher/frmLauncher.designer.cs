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
            this.gbGamePath.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.gbGamePath.Location = new System.Drawing.Point(13, 13);
            this.gbGamePath.Name = "gbGamePath";
            this.gbGamePath.Size = new System.Drawing.Size(334, 81);
            this.gbGamePath.TabIndex = 0;
            this.gbGamePath.TabStop = false;
            this.gbGamePath.Text = "Game Path";
            // 
            // btnBrowse
            // 
            this.btnBrowse.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnBrowse.Location = new System.Drawing.Point(253, 49);
            this.btnBrowse.Name = "btnBrowse";
            this.btnBrowse.Size = new System.Drawing.Size(75, 23);
            this.btnBrowse.TabIndex = 1;
            this.btnBrowse.Text = "Browse";
            this.btnBrowse.UseVisualStyleBackColor = true;
            this.btnBrowse.Click += new System.EventHandler(this.btnBrowse_Click);
            // 
            // txtGamePath
            // 
            this.txtGamePath.Location = new System.Drawing.Point(7, 20);
            this.txtGamePath.Name = "txtGamePath";
            this.txtGamePath.Size = new System.Drawing.Size(321, 23);
            this.txtGamePath.TabIndex = 0;
            // 
            // btnLaunch
            // 
            this.btnLaunch.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnLaunch.Location = new System.Drawing.Point(13, 100);
            this.btnLaunch.Name = "btnLaunch";
            this.btnLaunch.Size = new System.Drawing.Size(334, 58);
            this.btnLaunch.TabIndex = 1;
            this.btnLaunch.Text = "Launch Game";
            this.btnLaunch.UseVisualStyleBackColor = true;
            this.btnLaunch.Click += new System.EventHandler(this.btnLaunch_Click);
            // 
            // frmLauncher
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(359, 167);
            this.Controls.Add(this.btnLaunch);
            this.Controls.Add(this.gbGamePath);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "frmLauncher";
            this.Text = "BL2 SDK Launcher";
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

