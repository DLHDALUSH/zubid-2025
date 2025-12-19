package com.zubid.app.ui.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.zubid.app.databinding.ItemHelpBinding
import com.zubid.app.ui.activity.HelpItem

class HelpItemAdapter(
    private val onItemClick: (HelpItem) -> Unit
) : ListAdapter<HelpItem, HelpItemAdapter.HelpItemViewHolder>(HelpItemDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): HelpItemViewHolder {
        val binding = ItemHelpBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return HelpItemViewHolder(binding)
    }

    override fun onBindViewHolder(holder: HelpItemViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class HelpItemViewHolder(
        private val binding: ItemHelpBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        init {
            binding.root.setOnClickListener {
                val position = bindingAdapterPosition
                if (position != RecyclerView.NO_POSITION) {
                    onItemClick(getItem(position))
                }
            }
        }

        fun bind(helpItem: HelpItem) {
            binding.apply {
                titleText.text = helpItem.title
                descriptionText.text = helpItem.description
            }
        }
    }

    private class HelpItemDiffCallback : DiffUtil.ItemCallback<HelpItem>() {
        override fun areItemsTheSame(oldItem: HelpItem, newItem: HelpItem): Boolean {
            return oldItem.action == newItem.action
        }

        override fun areContentsTheSame(oldItem: HelpItem, newItem: HelpItem): Boolean {
            return oldItem == newItem
        }
    }
}
